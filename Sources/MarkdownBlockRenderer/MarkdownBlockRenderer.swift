import Markdown
import Foundation
import CryptoKit

public struct MarkdownBlockRenderer<Target, Content>
where Target: Markdown.BlockMarkup,
	  Content: DataConvertible {
	public enum RenderingError: Error {
		case dataConversionFailed(Content)
	}

	let outputDirectory: URL
	let extractContent: (Target) -> Content

	public init(
		outputDirectory: URL,
		extractContent: @escaping (Target) -> Content
	) {
		self.outputDirectory = outputDirectory
		self.extractContent = extractContent
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
			let result = try await render(target: collectedBlock)
			renderedBlocks.append((collectedBlock, result))
		}

		return renderedBlocks.map(\.1)
	}

	func render(target: Target) async throws(DataConversionFailed) -> URL {
		let content = extractContent(target)
		let contentHash = try self.contentHash(content: content)
		let filename = "rendered-" + contentHash
		let url = outputDirectory
			.appending(path: filename)
			// .appendingPathExtension("png") // TODO: Renderer declares output type
		// TODO: render into file at URL
		return url
	}

	func contentHash(content: Content) throws(DataConversionFailed) -> String {
		let data = try content.data()
		let digest = SHA256.hash(data: data)
		return digest
			.map { String(format: "%02x", $0) }
			.joined()
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
