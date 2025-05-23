import Markdown

public struct CodeBlockResult: ResultMarkup {
	let _debugDescription: (_ options: MarkupDumpOptions) -> String
	let _nextSibling: () -> (any Markdown.Markup)?

	public let language: String
	public let code: String
	public var content: String { code }
	public let range: SourceRange

	public init(_ base: DocumentEmbedded<CodeBlock>) {
		self.language = base.markup.language ?? ""
		self.code = base.markup.code
		self._debugDescription = { base.markup.debugDescription(options: $0) }
		self._nextSibling = { base.nextSibling() }
		self.range = base.range
	}

	public func nextSibling() -> (any Markdown.Markup)? {
		return _nextSibling()
	}

	public func debugDescription(options: MarkupDumpOptions = []) -> String {
		return _debugDescription(options)
	}
}
