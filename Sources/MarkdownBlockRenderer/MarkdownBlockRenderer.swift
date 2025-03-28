import CryptoKit
import Foundation
import Markdown

public struct MarkdownBlockRenderer<Block, Content>
where
	Block: Markdown.BlockMarkup,
	Content: DataConvertible
{
	public enum RenderingError: Error {
		case dataConversionFailed(Content)
	}

	public typealias Render = (
		_ content: Content,
		_ url: URL
	) throws -> Void

	let outputDirectory: URL
	let render: Render
	let fileExtension: String

	public init(
		outputDirectory: URL,
		fileExtension: String,
		render: @escaping Render
	) {
		self.outputDirectory = outputDirectory
		self.fileExtension = fileExtension
		self.render = render
	}

	public func render(
		_ target: Block,
		_ toString: (Block) -> Content
	) throws -> URL {
		let content = toString(target)
		let contentHash = try self.contentHash(content: content)
		let filename = "rendered-" + contentHash
		let url =
			outputDirectory
			.appending(path: filename)
			.appendingPathExtension(fileExtension)
		if FileManager.default.fileExists(atPath: url.path()) {
			return url
		}
		try self.render(content, url)
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
