import ArgumentParser
import DynamicJSON
import Foundation
import Markdown
import MarkdownBabel

struct SelectCommand: ParsableCommand {
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

	func run() throws {
		let document = try markdownDocument()
		let location = try sourceLocation()
		let context = document.executableContext(at: location)
		let response = json(context: context, location: location)
		FileHandle.standardOutput.write(try response.data())
	}
}

func json(context: ExecutableContext?, location: SourceLocation) -> JSON {
	guard let context else { return [:] }

	var jsonResult: [String: JSON] = [
		"range": json(location..<location),
		"input": json(context.codeBlock),
	]
	if let result = context.result {
		jsonResult["result"] = json(result)
	}
	if let error = context.error {
		jsonResult["error"] = json(error)
	}
	return .object(jsonResult)
}
