extension MarkdownBlockSelector: Transformer {
	public typealias From = Target
	public typealias To = Output

	public func pipe(to sink: NonThrowingSink<Output>) {
		var visitor = BlockTargetVisitor { visitedBlock in
			let output = self.visitor(visitedBlock)
			sink(output)
		}
		visitor.visit(self.document)
	}

	public func pipe(to sink: ThrowingSink<Output>) throws {
		var error: (any Error)?
		var visitor = BlockTargetVisitor { visitedBlock in
			guard error == nil else { return }

			let output = self.visitor(visitedBlock)
			do {
				try sink(output)
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
