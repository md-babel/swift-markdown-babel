import Markdown

struct TargetMarkupVisitor<Target>: Markdown.MarkupWalker
where Target: Markdown.Markup {
	typealias Visitor = (_ element: Target) -> Void

	let recurseIntoTarget: Bool
	let visit: Visitor

	init(
		recurseIntoTarget: Bool = false,
		visit: @escaping Visitor
	) {
		self.recurseIntoTarget = recurseIntoTarget
		self.visit = visit
	}

	mutating func defaultVisit(_ markup: any Markup) {
		if let target = markup as? Target {
			visit(target)
			if recurseIntoTarget {
				descendInto(markup)
			}
		} else {
			descendInto(markup)
		}
	}
}
