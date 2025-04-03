import Foundation
import Markdown

public typealias AnyElement = any Markdown.Markup

public protocol Document {
	func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> Markdown.Document
}

extension Document {
	public func markdown() -> Markdown.Document {
		return self.markdown(visitor: { $0 })
	}
}

public struct MarkdownDocument: Document {
	let document: Markdown.Document

	public init(parsing url: URL) throws {
		self.document = try .init(parsing: url)
	}

	public init(parsing string: String) {
		self.document = .init(parsing: string)
	}

	public func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> Markdown.Document {
		var visitor = AnyMarkupRewriter(transform: visitor)
		return visitor.visit(document) as! Markdown.Document
	}
}
