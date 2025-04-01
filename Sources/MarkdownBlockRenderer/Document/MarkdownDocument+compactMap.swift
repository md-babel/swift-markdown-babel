import Markdown

extension MarkdownDocument {
	public func compactMap<Transformation>(
		_ transform: @escaping (any Markdown.Markup) -> Transformation?
	) -> CompactMap<InitialDocument, Transformation> {
		return CompactMap(
			from: InitialDocument(document: self),
			transform: transform
		)
	}
}
