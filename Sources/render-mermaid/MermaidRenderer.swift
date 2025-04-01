import Foundation
import Markdown
import MarkdownBlockRenderer

struct MermaidRenderer {
	let mermaidPath: String
	let document: MarkdownDocument
	let outputDirectory: URL
	let outputFileExtension: String
	let log: VerboseLogger

	init(
		mermaidPath: String,
		document: consuming MarkdownDocument,
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

	struct MermaidRenderError: Error {
		let code: String
		let targetURL: URL
		let wrapped: (any Error)?
	}

	func render() async throws {
		let renderer = MarkdownBlockRenderer<Markdown.CodeBlock, String>(
			outputDirectory: outputDirectory,
			fileExtension: outputFileExtension
		) { (code: String, url: URL) throws in
			let path = url.path(percentEncoded: false)
			let stdin = try Pipe.stdin(string: code)
			let stdout = Pipe()
			let stderr = Pipe()
			let process = Process()
			process.executableURL = URL(fileURLWithPath: mermaidPath)
			process.arguments = [
				"-i", "-",
				"-o", path,
			]
			process.standardInput = stdin
			process.standardError = stderr
			process.standardOutput = stdout

			defer {
				if log.isEnabled {
					let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
					try! FileHandle.standardOutput.write(contentsOf: outputData)
				}
			}

			do {
				try process.run()
				process.waitUntilExit()

				if process.terminationStatus != 0 {
					let stderrMessage = String(
						data: stderr.fileHandleForReading.readDataToEndOfFile(),
						encoding: .utf8
					)
					throw RenderError(
						message: stderrMessage ?? "Process terminated with exit code \(process.terminationStatus)"
					)
				}
			} catch {
				throw MermaidRenderError(
					code: code,
					targetURL: url,
					wrapped: error
				)
			}
		}

		var files: [URL] = []
		try document
			.forEach(Markdown.CodeBlock.self)
			.where { $0.language?.lowercased() == "mermaid" }
			.do { (codeBlock: Markdown.CodeBlock) in  // -> Markdown.CustomBlock in
				let file = try renderer.render(codeBlock, \Markdown.CodeBlock.code)
				files.append(file)
				let commentBlock = Markdown.Paragraph(Markdown.Text("Test"))
				// return Markdown.CustomBlock(codeBlock, commentBlock)
			}
		print(files)
	}
}
