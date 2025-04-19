import Markdown

public protocol ResultMarkup {
	associatedtype BaseMarkup: ResultMarkupConvertible where BaseMarkup.ResultMarkupConversion == Self

	var content: String { get }
	var range: SourceRange { get }

	init(_ base: DocumentEmbedded<BaseMarkup>)

	func nextSibling() -> (any Markdown.Markup)?

	func debugDescription(options: MarkupDumpOptions) -> String
}
