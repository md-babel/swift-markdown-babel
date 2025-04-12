import Markdown

extension EvaluatorRegistry {
	func evaluator(
		forCodeBlock codeBlock: Markdown.CodeBlock
	) throws(EvaluatorRegistryFailure) -> Evaluator {
		let configuration = try configuration(forCodeBlock: codeBlock)
		return Evaluator(configuration: configuration)
	}
}
