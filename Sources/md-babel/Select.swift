import ArgumentParser
import Foundation
import Markdown
import MarkdownBlockRenderer

struct Select: ParsableCommand {
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
		} else if let string = readLine() {
			return MarkdownDocument(parsing: string)
		} else {
			// To test this, try to `readLine()` twice; the second one will fail because STDIN has already been emptied.
			throw GenericError(message: "Provide either non-empty STDIN or input file")
		}
	}

	// MARK: - Location

	// TODO: Transform i>=1
	@Option var line: Int
	@Option var column: Int

	func sourceLocation() throws -> Markdown.SourceLocation {
		Markdown.SourceLocation(line: line, column: column, source: inputFile)
	}

	func run() throws {
		let document = try markdownDocument()
		let location = try sourceLocation()
		let context = document.executableContext(at: location)
		print(format(context: context, location: location))
	}
}

func format(_ location: SourceLocation) -> String {
	"{ \"line\": \(location.line), \"column\": \(location.column) }"
}

func format(_ range: SourceRange) -> String {
	"{ \"from\": \(format(range.lowerBound)), \"to\": \(format(range.upperBound)) }"
}

func sanitize(_ string: String) -> String {
	return
		string
		.trimmingCharacters(in: .newlines)
		.replacing("\n", with: "\\n")
		.replacing("\r", with: "\\r")
}

func format(_ markup: CodeBlock) -> String {
	return [
		"{",
		format(
			indentation: 2,
			"\"range\": \(format(markup.range!))",
			"\"type\": \"code_block\"",
			"\"language\": \"\(markup.language ?? "")\"",
			"\"content\": \"\(sanitize(markup.code))\"",
			separator: ",\n"
		),
		"  }",
	].joined(separator: "\n")
}

func format(_ result: ExecutableContext.Result) -> String {
	return [
		"{",
		format(
			indentation: 2,
			"\"range\": \(format(result.range))",
			"\"header\": \(result.header)",
			"\"type\": \"code_block\"",
			"\"language\": \"\(result.contentMarkup.language ?? "")\"",
			"\"content\": \"\(sanitize(result.content))\"",
			separator: ",\n"
		),
		"  }",
	].joined(separator: "\n")
}

func format(_ error: ExecutableContext.Error) -> String {
	return [
		"{",
		format(
			indentation: 2,
			"\"range\": \(format(error.range))",
			"\"header\": \(error.header)",
			"\"type\": \"code_block\"",
			"\"language\": \"\(error.contentMarkup.language ?? "")\"",
			"\"content\": \"\(sanitize(error.content))\"",
			separator: ",\n"
		),
		"  }",
	].joined(separator: "\n")
}

func format(
	indentation: Int = 0,
	lines: [String],
	separator: String
) -> String {
	let indent = (0..<indentation).map { _ in "  " }.joined()
	return lines.map { indent + $0 }.joined(separator: separator)
}

func format(
	indentation: Int = 0,
	_ lines: String...,
	separator: String
) -> String {
	return format(
		indentation: indentation,
		lines: lines.compactMap { $0 },
		separator: separator
	)
}

func format(
	indentation: Int = 0,
	_ lines: String?...,
	separator: String
) -> String {
	return format(
		indentation: indentation,
		lines: lines.compactMap { $0 },
		separator: separator
	)
}

func format(context: ExecutableContext?, location: SourceLocation) -> String {
	guard let context else { return "" }

	return [
		"{",
		format(
			indentation: 1,
			"\"range\": \(format(location ..< location))",
			"\"input\": \(format(context.codeBlock))",
			context.result.map(format(_:)).map { #""result": "# + $0 },
			context.error.map(format(_:)).map { #""error": "# + $0 },
			separator: ",\n"
		),
		"}",
	].joined(separator: "\n")
}
