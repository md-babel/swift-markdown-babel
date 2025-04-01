import Markdown

/// Start of a transformation chain visiting all document elements.
public struct InitialDocument: Transformer {
	public typealias From = Void
	public typealias To = AnyMarkupWalker.AnyMarkup

	public let document: MarkdownDocument

	public func pipe(to sink: NonThrowingSink<To>) {
		var visitor = AnyMarkupWalker { sink($0) }
		visitor.visit(self.document)
	}

	public func pipe(to sink: ThrowingSink<To>) throws {
		var error: (any Error)?
		var visitor = AnyMarkupWalker { markup in
			guard error == nil else { return }

			do {
				try sink(markup)
			} catch let e {
				error = e
			}
		}
		visitor.visit(self.document)
		if let error {
			throw error
		}
	}
}
