import Markdown

extension MarkdownDocument {
	public func markup(at sourceLocation: Markdown.SourceLocation) -> (any Markdown.Markup)? {
		var walker = LeafMarkupAtLocationWalker(location: sourceLocation)
		self.document.accept(&walker)
		return walker.match
	}

	public func executableContext(at sourceLocation: Markdown.SourceLocation) -> ExecutableContext? {
		guard let codeBlockAtLocation = markup(at: sourceLocation) as? Markdown.CodeBlock else { return nil }
		return ExecutableContext(
			codeBlock: codeBlockAtLocation
		)
	}
}

private struct LeafMarkupAtLocationWalker: Markdown.MarkupWalker {
	let location: Markdown.SourceLocation
	var match: (any Markdown.Markup)?

	mutating func defaultVisit(_ markup: any Markup) {
		guard let range = markup.range else { return }
		guard range.contains(location) else { return }
		self.match = markup

		// Just use the default implementation until we have actual pressure to
		// optimize.
		//
		// The default implementation has no early exit: in the case of
		// `Document`, we would walk all root-level nodes, producing worst-case
		// scenarios in long documents where the search `location` is at the
		// very beginning. While that does sound wastful, and while there is
		// potential to override the default implementation and exit early, we
		// should only do that with performance measurements in place. Otherwise
		// we risk increasing the amount of work for negligible edge case
		// efficiency:
		//
		//     for child in markup.children {
		//       if child.range?.lowerBound > location { return }  // <- duplicate work for range checks
		//       visit(child)
		//     }

		descendInto(markup)
	}
}
