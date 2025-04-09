import Markdown

extension Markdown.Document: Document {
	public func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> Markdown.Document {
		var visitor = AnyMarkupRewriter(transform: visitor)
		return visitor.visit(self) as! Markdown.Document
	}

	public func markdown() -> Markdown.Document {
		return self
	}
}
