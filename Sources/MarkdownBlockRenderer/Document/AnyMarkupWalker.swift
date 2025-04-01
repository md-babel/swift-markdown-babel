import Markdown

public struct AnyMarkupWalker: Markdown.MarkupWalker {
	public typealias AnyMarkup = any Markup

	public let visitor: (AnyMarkup) -> Void

	public mutating func defaultVisit(_ markup: any Markup) {
		visitor(markup)
		descendInto(markup)
	}
}
