import Markdown
import Foundation

public struct MarkdownBlockRenderer<Target>
where Target: Markdown.BlockMarkup {
	let outputDirectory: URL

	public init(outputDirectory: URL) {
		self.outputDirectory = outputDirectory
	}

	public func renderedFiles(
		document: Markdown.Document
	) async throws -> [URL] {
		return []
	}

	func render(block: Target) async throws -> URL {
		fatalError()
	}
}
