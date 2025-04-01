import Markdown

extension MarkdownDocument {
	public func map<Transformation>(
		_ transform: @escaping (any Markdown.Markup) -> Transformation
	) -> Map<InitialDocument, Transformation> {
		return Map(
			from: InitialDocument(document: self),
			transform: transform
		)
	}
}
