extension MarkdownBlockSelector: Transformer {
	public typealias From = Target
	public typealias To = Output

	public func pipe(to sink: Sink<Output>) {
		var visitor = BlockTargetVisitor { visitedBlock in
			let output = self.visitor(visitedBlock)
			sink(output)
		}
		visitor.visit(self.document)
	}
}
