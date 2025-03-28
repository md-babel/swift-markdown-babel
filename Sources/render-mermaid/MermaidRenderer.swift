import Foundation
import Markdown
import MarkdownBlockRenderer

struct MermaidRenderer {
	let mermaidPath: String
	let document: Markdown.Document
	let outputDirectory: URL
	let outputFileExtension: String
	let log: VerboseLogger

	init(
		mermaidPath: String,
		document: consuming Markdown.Document,
		outputDirectory: URL,
		outputFileExtension: String,
		log: VerboseLogger
	) {
		self.mermaidPath = mermaidPath
		self.document = document
		self.outputDirectory = outputDirectory
		self.outputFileExtension = outputFileExtension
		self.log = log
	}

	func callAsFunction() async throws {
		try await render()
	}

	func render() async throws {
		let renderer = MarkdownBlockRenderer<Markdown.CodeBlock, String>(
			outputDirectory: outputDirectory,
			fileExtension: outputFileExtension,
			extractContent: \.code
		) { (code: String, url: URL) async throws in
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

			if log.isEnabled {
				let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
				try FileHandle.standardOutput.write(contentsOf: outputData)
			}
		}

		let files = try await renderer.renderedFiles(document: document)

		print(files)
	}
}
