import ArgumentParser
import DynamicJSON
import Foundation
import Markdown
import MarkdownBabel

struct ExecuteCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "execute",
		abstract: "Execute code blocks",
		aliases: ["exec"]
	)

	// MARK: - Input File

	@Option(
		name: [.customShort("f"), .customLong("file")],
		help: "Input file path.",
		transform: { URL(fileURLWithPath: $0) }
	)
	var inputFile: URL?

	func markdownDocument() throws -> MarkdownDocument {
		if let inputFile {
			return try MarkdownDocument(parsing: inputFile)
		} else if let string = try stringFromStdin() {
			return MarkdownDocument(parsing: string)
		} else {
			// To test this, try to `readLine()` twice; the second one will fail because STDIN has already been emptied.
			throw GenericError(message: "Provide either non-empty STDIN or input file")
		}
	}

	// MARK: - Location

	@Option(
		name: .shortAndLong,
		help: "Line position of the insertion point in file. (1-based)",
		transform: positiveNonZero(_:)
	)
	var line: Int
	@Option(
		name: .shortAndLong,
		help: "Column position of the insertion point in file at line. (1-based)",
		transform: positiveNonZero(_:)
	)
	var column: Int

	func sourceLocation() throws -> Markdown.SourceLocation {
		Markdown.SourceLocation(line: line, column: column, source: inputFile)
	}

	// MARK: - Config File

	@Option(
		name: .customLong("config"),
		help: "Config file path.",
		transform: { URL(fileURLWithPath: $0) }
	)
	var configFile: URL?

	@Flag(
		name: .customLong("load-user-config"),
		inversion: .prefixedNo,
		exclusivity: .exclusive,
		help: ArgumentHelp(
			"Whether to load the user's global config file.",
			discussion:
				"Disabling the global user configuration without setting --config will result in no context being recognized."
		)
	)
	var loadUserConfig = true

	func executableRegistry() throws -> ExecutableRegistry {
		let fromXDG: [String: ExecutableConfiguration] =
			if loadUserConfig {
				(try? ExecutableConfiguration.configurations(jsonFileAtURL: xdgConfigURL)) ?? [:]
			} else {
				[:]
			}
		let fromFile = try configFile.map(ExecutableConfiguration.configurations(jsonFileAtURL:)) ?? [:]

		var configurations: [String: ExecutableConfiguration] = [:]
		configurations.merge(fromXDG) { _, new in new }
		configurations.merge(fromFile) { _, new in new }

		return ExecutableRegistry(configurations: configurations)
	}

	// MARK: - Run

	func run() async throws {
		let document = try markdownDocument()
		let location = try sourceLocation()
		guard let context = document.executableContext(at: location) else {
			// TODO: Produce "nothing found" response. https://github.com/md-babel/swift-markdown-babel/issues/15
			FileHandle.standardOutput.write(try JSON.object([:]).data())
			return
		}
		let registry = try executableRegistry()
		let executionResult: ExecutionResult = await {
			do {
				let executable = try registry.executable(forCodeBlock: context.codeBlock)
				let result = try await executable.run(code: context.codeBlock.code)
				return ExecutionResult(output: result, error: nil)
			} catch {
				return ExecutionResult(output: nil, error: "\(error)")
			}
		}()

		let response = json(location: location, executableContext: context, executionResult: executionResult)
		let data = try response.data(formatting: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
		FileHandle.standardOutput.write(data)
	}
}

extension ExecutionResult {
	func outputBlocks(reusing oldResult: ExecutableContext.Result?) -> [any BlockMarkup] {
		guard let output else { return [] }
		let header: String = oldResult?.header ?? "Result:"
		return [
			HTMLCommentBlock(htmlBlock: HTMLBlock("<!--\(header)-->"))!,
			CodeBlock(language: nil, output),
		]
	}

	func errorBlocks(reusing oldError: ExecutableContext.Error?) -> [any BlockMarkup] {
		guard let message = self.error else { return [] }
		let header: String = oldError?.header ?? "Error:"
		return [
			HTMLCommentBlock(htmlBlock: HTMLBlock("<!--\(header)-->"))!,
			CodeBlock(language: nil, message),
		]
	}
}

func json(
	location: SourceLocation,
	executableContext: ExecutableContext,
	executionResult: ExecutionResult
) -> JSON {
	let document = Document(
		[
			[executableContext.codeBlock],
			executionResult.outputBlocks(reusing: executableContext.result),
			executionResult.errorBlocks(reusing: executableContext.error),
		].flatMap { $0 }
	)
	let renderedString = document.format()
	var jsonResult: [String: JSON] = [
		"range": json(location..<location),
		"replacementRange": json(executableContext.encompassingRange),
		"replacementString": .string(renderedString),
	]
	if let output = executionResult.output {
		jsonResult["result"] = .string(output)
	}
	if let error = executionResult.error {
		jsonResult["error"] = .string(error)
	}
	return .object(jsonResult)
}
