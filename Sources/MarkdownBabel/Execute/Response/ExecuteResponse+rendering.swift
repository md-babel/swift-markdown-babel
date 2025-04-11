import Markdown

extension ExecuteResponse.ExecutionResult {
	func outputBlocks(reusing oldResult: ExecutableContext.Result?) -> [any BlockMarkup] {
		guard let output else { return [] }
		let header: String = oldResult?.header ?? "Result:"
		return [
			HTMLCommentBlock(htmlBlock: HTMLBlock("<!--\(header)-->"))!,
			CodeBlock(language: nil, output),
		]
	}

	func errorBlocks(reusing oldError: ExecutableContext.Error?) -> [any BlockMarkup] {
		guard let message = self.error else { return [] }
		let header: String = oldError?.header ?? "Error:"
		return [
			HTMLCommentBlock(htmlBlock: HTMLBlock("<!--\(header)-->"))!,
			CodeBlock(language: nil, message),
		]
	}
}

extension ExecuteResponse {
	public func rendered() -> String {
		let document = Markdown.Document(
			[
				[self.executableContext.codeBlock],
				executionResult.outputBlocks(reusing: executableContext.result),
				executionResult.errorBlocks(reusing: executableContext.error),
			].flatMap { $0 }
		)
		return document.format(options: .init(useCodeFence: .always))
	}
}
