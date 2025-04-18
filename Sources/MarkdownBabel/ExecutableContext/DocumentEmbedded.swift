import Markdown

/// Guarantees that its `markup` node is from a document with a `SourceRange`.
public struct DocumentEmbedded<M> where M: Markdown.Markup {
	public let markup: M
	public let range: SourceRange

	public init?(_ markup: M) {
		guard let range = markup.range else { return nil }
		self.markup = markup
		self.range = range
	}
}

extension DocumentEmbedded {
	public func nextSibling() -> (any Markdown.Markup)? {
		return markup.nextSibling()
	}
}

extension Markdown.Markup {
	func embedded() -> DocumentEmbedded<Self>? {
		return DocumentEmbedded(self)
	}
}

extension DocumentEmbedded where M: ResultMarkupConvertible {
	func makeResultMarkup() -> M.ResultMarkupConversion {
		return M.ResultMarkupConversion(self)
	}
}
