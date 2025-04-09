import Markdown

extension Markdown.Markup {
	func nextSibling() -> (any Markdown.Markup)? {
		guard let parent else { return nil }
		return parent.child(at: indexInParent + 1)
	}
}
