import ArgumentParser
import MarkdownBlockRenderer
import Foundation
import Markdown

extension Pipe {
	static func stdin(string: String) throws -> Pipe {
		let stdin = Pipe()
		try stdin.fileHandleForWriting.write(contentsOf: string.data())
		try stdin.fileHandleForWriting.close()
		return stdin
	}
}

@main
struct RenderMermaid: AsyncParsableCommand {
	@Option(
		name: [.customShort("m"), .customLong("mermaid")],
		help: "Path to the mmdc executable."
	)
	var mermaidPath: String

	@Option(
		name: [.customShort("i"), .customLong("input")],
		help: "Input file path.",
		transform: { URL(fileURLWithPath: $0) }
	)
	var inputFile: URL?

	@Flag(
		name: [.customShort("v"), .customLong("verbose")],
		help: "Print render status to standard output."
	)
	var verbose: Bool = false

	func markdownDocument() throws -> Markdown.Document {
		if let inputFile {
			return try Document(parsing: inputFile)
		} else if let string = readLine() {
			return Document(parsing: string)
		} else {
			throw ArgumentParser.ValidationError("Provide either STDIN or \(_inputFile.description)")
		}
	}

	mutating func run() async throws {
		let document = try markdownDocument()

		let tmpDir = FileManager.default.temporaryDirectory
		try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
		let mermaidPath = self.mermaidPath
		let renderer = MarkdownBlockRenderer<Markdown.CodeBlock, String>(
			outputDirectory: tmpDir,
			fileExtension: "png",
			extractContent: \.code
		) { [verbose] (code: String, url: URL) in
			let path = url.path(percentEncoded: false)
			let stdin = try Pipe.stdin(string: code)
			let stdout = Pipe()
			let process = Process()
			process.executableURL = URL(fileURLWithPath: mermaidPath)
			process.arguments = [
				"-i", "-",
				"-o", path,
			]
			process.standardInput = stdin
			process.standardError = FileHandle.standardError
			process.standardOutput = stdout
			try process.run()

			if verbose {
				let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
				try FileHandle.standardOutput.write(contentsOf: outputData)
			}
		}

		let files = try await renderer.renderedFiles(document: document)

		print(files)
	}
}
