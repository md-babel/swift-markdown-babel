import ArgumentParser
import Foundation
import Markdown
import MarkdownBlockRenderer

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

	// MARK: - Run

	func run() async throws {
		let document = try markdownDocument()
		let location = try sourceLocation()
		guard let context = document.executableContext(at: location) else {
			return  // TODO: throw error? produce not-found response?
		}
		// TODO: Escalate hydrading configurations from ~/.config/ and ~/Library/Application Support/ and local path and --config parameter, and offer --no-user-config to skip shared config completely.
		let registry = ExecutableRegistry(configurations: [
			"sh": .init(executableURL: URL(fileURLWithPath: "/usr/bin/env"), arguments: ["sh"])
		])
		let executionResult: ExecutionResult = await {
			do {
				let executable = try registry.executable(forCodeBlock: context.codeBlock)
				let result = try await executable.run(code: context.codeBlock.code)
				return ExecutionResult(output: result, error: nil)
			} catch {
				return ExecutionResult(output: nil, error: "\(error)")
			}
		}()

		print(format(location: location, executableContext: context, executionResult: executionResult))
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

func format(
	location: SourceLocation,
	executableContext: ExecutableContext,
	executionResult: ExecutionResult
) -> String {
	let document = Document(
		[
			[executableContext.codeBlock],
			executionResult.outputBlocks(reusing: executableContext.result),
			executionResult.errorBlocks(reusing: executableContext.error),
		].flatMap { $0 }
	)
	let renderedString = document.format()
	return [
		"{",
		format(
			indentation: 1,
			"\"range\": \(format(location ..< location))",
			"\"replacementRange\": \(format(executableContext.encompassingRange))",
			"\"replacementString\": \"\(sanitize(renderedString))\"",
			executionResult.output.map(sanitize(_:)).map { "\"result\": \"\($0)\"" },
			executionResult.error.map(sanitize(_:)).map { "\"error\": \"\($0)\"" },
			separator: ",\n"
		),
		"}",
	].joined(separator: "\n")
}
