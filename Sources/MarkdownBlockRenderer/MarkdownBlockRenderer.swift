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
		var collectedBlocks: [Target] = []
		var visitor = TargetVisitor { target in
			collectedBlocks.append(target)
		}
		visitor.visit(document)

		var renderedBlocks: [(Target, URL)] = []
		for collectedBlock in collectedBlocks {
			let result = try await render(block: collectedBlock)
			renderedBlocks.append((collectedBlock, result))
		}

		return renderedBlocks.map(\.1)
	}

	func render(block: Target) async throws -> URL {
		// TODO: Compute hash string
		let hash = "rendered-" + String(block.format().hashValue)
		let url = outputDirectory.appending(path: hash)
		// TODO: render into file at URL
		return url
	}
}

struct TargetVisitor<Target>: Markdown.MarkupWalker
where Target: Markdown.BlockMarkup {
	let visit: (Target) -> ()

	mutating func defaultVisit(_ markup: any Markup) -> () {
		if let target = markup as? Target {
			visit(target)
		} else {
			descendInto(markup)
		}
	}
}
