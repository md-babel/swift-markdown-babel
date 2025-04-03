import Markdown

public protocol DocumentScope<Element> {
	associatedtype Element: Markdown.Markup
}
