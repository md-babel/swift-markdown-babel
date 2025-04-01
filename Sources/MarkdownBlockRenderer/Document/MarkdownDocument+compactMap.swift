import Markdown

extension MarkdownDocument {
	@inlinable @inline(__always)
	public func compactMap<Transformation>(
		_ transform: @escaping (any Markdown.Markup) -> Transformation?
	) -> CompactMap<InitialDocument, Transformation> {
		return CompactMap(
			from: InitialDocument(document: self),
			transform: transform
		)
	}
}
