import CryptoKit
import Foundation
import Markdown

public struct MarkdownBlockRenderer<Target, Content>
where
	Target: Markdown.BlockMarkup,
	Content: DataConvertible
{
	public enum RenderingError: Error {
		case dataConversionFailed(Content)
	}

	public typealias Render = (
		_ content: Content,
		_ url: URL
	) async throws -> Void

	let outputDirectory: URL
	let extractContent: (Target) -> Content
	let render: Render
	let fileExtension: String

	public init(
		outputDirectory: URL,
		fileExtension: String,
		extractContent: @escaping (Target) -> Content,
		render: @escaping Render
	) {
		self.outputDirectory = outputDirectory
		self.fileExtension = fileExtension
		self.extractContent = extractContent
		self.render = render
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

	func render(target: Target) async throws -> URL {
		let content = extractContent(target)
		let contentHash = try self.contentHash(content: content)
		let filename = "rendered-" + contentHash
		let url =
			outputDirectory
			.appending(path: filename)
			.appendingPathExtension(fileExtension)
		if FileManager.default.fileExists(atPath: url.path()) {
			return url
		}
		try await self.render(content, url)
		return url
	}

	func contentHash(content: Content) throws(DataConversionFailed) -> String {
		let data = try content.data()
		let digest = SHA256.hash(data: data)
		return
			digest
			.map { String(format: "%02x", $0) }
			.joined()
	}
}

struct TargetVisitor<Target>: Markdown.MarkupWalker
where Target: Markdown.BlockMarkup {
	let visit: (Target) -> Void

	mutating func defaultVisit(_ markup: any Markup) {
		if let target = markup as? Target {
			visit(target)
		} else {
			descendInto(markup)
		}
	}
}
