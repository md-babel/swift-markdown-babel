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

	func evaluatorRegistry() throws -> EvaluatorRegistry {
		return try EvaluatorRegistry.load(fromXDG: self.loadUserConfig, fromFile: configFile)
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
		let execute = try Execute(executableContext: context, registry: evaluatorRegistry())
		let response = await execute()
		let data =
			try json(response, originalLocation: location)
			.data(formatting: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
		FileHandle.standardOutput.write(data)
	}
}

func json(_ response: Execute.Response, originalLocation location: SourceLocation) -> JSON {
	let renderedString = response.rendered()
	var jsonResult: [String: JSON] = [
		"range": json(location..<location),
		"replacementRange": json(response.executableContext.encompassingRange),
		"replacementString": .string(renderedString),
	]
	if let output = response.executionResult.output {
		jsonResult["result"] = .string(output)
	}
	if let error = response.executionResult.error {
		jsonResult["error"] = .string(error)
	}
	return .object(jsonResult)
}
