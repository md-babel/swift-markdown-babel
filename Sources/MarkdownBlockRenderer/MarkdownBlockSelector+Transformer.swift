extension MarkdownBlockSelector: Transformer {
	public func `do`(_ sink: @escaping (Output) -> Void) {
		var visitor = BlockTargetVisitor { visitedBlock in
			let output = self.visitor(visitedBlock)
			sink(output)
		}
		visitor.visit(self.document)
	}
}
