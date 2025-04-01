import Markdown

struct TargetMarkupVisitor<Target>: Markdown.MarkupWalker
where Target: Markdown.Markup {
	typealias Visitor = (_ element: Target) -> Void

	let descendIntoTargetChildren: Bool
	let visit: Visitor

	init(
		descendIntoTargetChildren: Bool = false,
		visit: @escaping Visitor
	) {
		self.descendIntoTargetChildren = descendIntoTargetChildren
		self.visit = visit
	}

	mutating func defaultVisit(_ markup: any Markup) {
		if let target = markup as? Target {
			visit(target)
			if descendIntoTargetChildren {
				descendInto(markup)
			}
		} else {
			descendInto(markup)
		}
	}
}
