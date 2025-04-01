import Markdown

/// Markup document walker that stops recursion at `Target` blocks.
struct BlockTargetVisitor<Target>: Markdown.MarkupWalker
where Target: Markdown.BlockMarkup {
	let visit: (_ visitedBlock: Target) -> Void

	mutating func defaultVisit(_ markup: any Markup) {
		if let target = markup as? Target {
			visit(target)
		} else {
			descendInto(markup)
		}
	}
}
