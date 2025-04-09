import Markdown

public struct RecursiveMarkupWalker: Markdown.MarkupWalker {
	public typealias AnyMarkup = any Markup
	public typealias Visitor = (
		_ markup: AnyMarkup,
		_ descendInto: (AnyMarkup) -> Void
	) -> Void

	public let visitor: Visitor

	init(visitor: @escaping Visitor) {
		self.visitor = visitor
	}

	public mutating func defaultVisit(_ markup: any Markup) {
		visitor(markup, { descendInto($0) })
	}
}

extension RecursiveMarkupWalker {
	init<Target>(
		recurseIntoTarget: Bool = false,
		visit: @escaping (_ element: Target) -> Void
	) where Target: Markdown.Markup {
		self.init { markup, descendInto in
			if let target = markup as? Target {
				visit(target)
				if recurseIntoTarget {
					descendInto(target)
				}
			} else {
				descendInto(markup)
			}
		}
	}
}
