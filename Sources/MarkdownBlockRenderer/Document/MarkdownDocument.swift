import Foundation
import Markdown

public struct MarkdownDocument: Document {
	let document: Markdown.Document

	public init(parsing url: URL) throws {
		self.document = try .init(parsing: url)
	}

	public init(parsing string: String) {
		self.document = .init(parsing: string)
	}

	public func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> Markdown.Document {
		return document.markdown(visitor: visitor)
	}

	public func markdown() -> Markdown.Document {
		return document.markdown { $0 }.markdown()
	}
}
