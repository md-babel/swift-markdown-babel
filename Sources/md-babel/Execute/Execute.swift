import ArgumentParser
import DynamicJSON
import Foundation
import Markdown
import MarkdownBabel

struct Execute: AsyncParsableCommand {
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

	func executableRegistry() throws -> ExecutableRegistry {
		let configurations: [String: ExecutableConfiguration]
		if let configFile {
			let data = try Data(contentsOf: configFile)
			let json = try JSON(data: data)
			configurations = try ExecutableConfiguration.configurations(fromJSON: json)
		} else {
			configurations = [:]
		}
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
		FileHandle.standardOutput.write(try response.data())
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
