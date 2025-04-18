import Markdown

extension Execute.Response.ExecutionResult.Insert {
	fileprivate func rendered() -> String {
		switch self {
		case .codeBlock(let language, let code):
			return CodeBlock(
				language: language,
				code.trimmingCharacters(in: .newlines)
			).format(options: .init(useCodeFence: .always))
		case .image(let path, let hash):
			return "![\(hash ?? "")](\(path))"
		}
	}
}

extension Execute.Response.ExecutionResult.Output {
	fileprivate func rendered() -> String {
		return self.insert.rendered()
	}
}

extension Execute.Response.ExecutionResult {
	fileprivate func renderedOutputBlocks(reusing oldResult: ExecutableContext.Result?) -> String? {
		guard let output else { return nil }
		let commentBlock = oldResult?.metadata.commentBlock.markup ?? ResultMetadataBlock.makeHTMLCommentBlock()
		return [
			commentBlock.format().trimmingCharacters(in: .whitespacesAndNewlines),
			output.rendered(),
		].joined(separator: "\n")
	}

	fileprivate func renderedErrorBlocks(reusing oldError: ExecutableContext.Error?) -> String? {
		guard let message = self.error else { return nil }
		let commentBlock = oldError?.metadata.commentBlock.markup ?? ErrorMetadataBlock.makeHTMLCommentBlock()
		return [
			commentBlock.format().trimmingCharacters(in: .whitespacesAndNewlines),
			CodeBlock(language: nil, message.trimmingCharacters(in: .newlines)).format(
				options: .init(useCodeFence: .always)
			),
		].joined(separator: "\n")
	}
}

extension Execute.Response {
	public func rendered() -> String {
		return [
			// CodeBlock.format() on its own will prepend two empty newlines; a Document with just a CodeBlock won't, so we wrap it:
			Markdown.Document(self.executableContext.codeBlock).format(options: .init(useCodeFence: .always)),
			executionResult.renderedOutputBlocks(reusing: executableContext.result),
			executionResult.renderedErrorBlocks(reusing: executableContext.error),
		]
		.compactMap { $0 }
		.joined(separator: "\n\n")
	}
}
