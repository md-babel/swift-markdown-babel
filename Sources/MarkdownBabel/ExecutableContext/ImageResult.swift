import Markdown

public struct ImageResult: ResultMarkup {
	let _debugDescription: (_ options: MarkupDumpOptions) -> String
	let _nextSibling: () -> (any Markdown.Markup)?

	public let title: String
	public let source: String
	public var content: String { source }
	public let range: SourceRange

	public init(_ base: DocumentEmbedded<Markdown.Image>) {
		self.title = base.markup.title ?? ""
		self.source = base.markup.source ?? ""
		self._debugDescription = { base.markup.debugDescription(options: $0) }
		self._nextSibling = { base.markup.nextSibling() }
		self.range = base.range
	}

	public func nextSibling() -> (any Markdown.Markup)? {
		return _nextSibling()
	}

	public func debugDescription(options: MarkupDumpOptions = []) -> String {
		return _debugDescription(options)
	}
}
