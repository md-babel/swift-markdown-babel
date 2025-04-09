import Markdown

/// General entry point into visiting (and potentially rewriting) every node in a Markdown document.
///
/// Overrides the default entry point declared in the protocol extension of `MarkupRewriter`,
/// ``defaultVisit(_:)``, to handle the existential `any Markup` directly, passing it to the
/// ``transform`` functor -- except for the one root `Document`, which will just be passed-through
/// directly.
///
/// The rewriter protocol commonly is implemented to provide replacements for the strongly-typed
/// `visit*` methods, so this is
public struct AnyMarkupRewriter: Markdown.MarkupRewriter {
	let transform: (AnyElement) -> AnyElement?

	private mutating func visitAnyMarkup(_ markup: AnyElement) -> AnyElement {
		let newChildren = markup.children.compactMap {
			return self.visit($0)
		}
		return markup.withUncheckedChildren(newChildren)
	}

	public mutating func defaultVisit(_ markup: AnyElement) -> AnyElement? {
		return transform(visitAnyMarkup(markup))
	}

	// While strongly-typed methods like `visitDocument` below are available for all publicly
	// declared block types, we can't use them as type-level constraints.

	public mutating func visitDocument(_ document: Markdown.Document) -> AnyElement? {
		return visitAnyMarkup(document)
	}
}
