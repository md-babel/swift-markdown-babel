import Markdown

public typealias AnyElement = any Markdown.Markup

public protocol Document {
	associatedtype VisitedDocument: Document
	func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> VisitedDocument
	func markdown() -> Markdown.Document
}
