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
	@Argument
	var mermaidPath: String

	mutating func run() async throws {
		let tmpDir = FileManager.default.temporaryDirectory
		try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
		let mermaidPath = self.mermaidPath
		let renderer = MarkdownBlockRenderer<Markdown.CodeBlock, String>(
			outputDirectory: tmpDir,
			fileExtension: "png",
			extractContent: \.code
		) { (code: String, url: URL) in
			let path = url.path(percentEncoded: false)
			print(path)
			let stdin = try Pipe.stdin(string: code)
			let stderr = Pipe()
			let process = Process()
			process.executableURL = URL(fileURLWithPath: mermaidPath)
			process.arguments = [
				"-i", "-",
				"-o", path,
			]
			process.standardInput = stdin
			process.standardError = stderr
			try process.run()
			let error = String(decoding: stderr.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
			print(error)
		}
		let document = Document(parsing:
			"""
			# Heading

			Text.

			```mermaid
			graph TD;
			  A-->B;
			  A-->C;
			  B-->D;
			  C-->D;
			```

			Text.

			```mermaid
			gitGraph
			   commit
			   commit
			   branch develop
			   commit
			   commit
			   commit
			   checkout main
			   commit
			   commit
			```

			Text.
			"""
		)

		let files = try await renderer.renderedFiles(document: document)

		print(files)
	}
}
