import Foundation
import Markdown

public struct MarkdownDocument: Document {
	public let string: String
	let document: Markdown.Document

	public init(parsing url: URL) throws {
		let string = try String(contentsOf: url)
		self.init(parsing: string)
	}

	public init(parsing string: String) {
		self.string = string
		self.document = .init(parsing: string)
	}

	public func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> Markdown.Document {
		return document.markdown(visitor: visitor)
	}

	public func markdown() -> Markdown.Document {
		return document.markdown { $0 }.markdown()
	}
}
