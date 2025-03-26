import ArgumentParser
import MarkdownBlockRenderer
import Foundation
import Markdown

@main
struct RenderMermaid: AsyncParsableCommand {
	mutating func run() async throws {
		let tmpDir = FileManager.default.temporaryDirectory
		let renderer = MarkdownBlockRenderer<Markdown.CodeBlock, String>(
			outputDirectory: tmpDir,
			extractContent: \.code
		)
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
			``mermaid

			Text.
			"""
		)

		let files = try await renderer.renderedFiles(document: document)

		print(files)
	}
}
