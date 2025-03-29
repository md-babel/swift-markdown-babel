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
			fileExtension: outputFileExtension
		) { (code: String, url: URL) throws in
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

		var files: [URL] = []
		document
			.forEach(Markdown.CodeBlock.self)
			.where { $0.language?.lowercased() == "mermaid" }
			.do { (codeBlock: Markdown.CodeBlock?) in
				guard let codeBlock else { return }
				let file = try! renderer.render(codeBlock, \Markdown.CodeBlock.code)
				files.append(file)
			}
		print(files)
	}
}
