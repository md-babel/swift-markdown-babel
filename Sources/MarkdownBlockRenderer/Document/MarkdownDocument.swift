import Foundation
import Markdown

public typealias AnyElement = any Markdown.Markup

public protocol Document {
	associatedtype VisitedDocument: Document
	func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> VisitedDocument
	func markdown() -> Markdown.Document
}

extension Document {
	public func markdown() -> Markdown.Document {
		return self.markdown(visitor: { $0 }).markdown()
	}
}

extension Markdown.Document: Document {
	public func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> Markdown.Document {
		var visitor = AnyMarkupRewriter(transform: visitor)
		return visitor.visit(self) as! Markdown.Document
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
		return document.markdown(visitor: visitor)
	}
}
