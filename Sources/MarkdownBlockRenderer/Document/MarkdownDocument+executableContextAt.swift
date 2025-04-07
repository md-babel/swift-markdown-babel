import Markdown

extension MarkdownDocument {
	public func executableContext(at sourceLocation: Markdown.SourceLocation) -> ExecutableContext? {
		guard let codeBlockAtLocation = markup(at: sourceLocation) as? Markdown.CodeBlock else { return nil }
		let result = { () -> ExecutableContext.Result? in
			guard let htmlBlock = codeBlockAtLocation.nextSibling() as? Markdown.HTMLBlock,
				let commentBlock = HTMLCommentBlock(htmlBlock: htmlBlock),
				commentBlock.commentedText.hasPrefix("Result:"),
				let resultCodeBlock = commentBlock.nextSibling() as? Markdown.CodeBlock
			else { return nil }
			return ExecutableContext.Result(
				markup: resultCodeBlock,
				header: commentBlock.commentedText,
				content: resultCodeBlock.code
			)
		}()
		let error = { () -> ExecutableContext.Error? in
			let referenceBlock = result?.markup ?? codeBlockAtLocation
			guard let htmlBlock = referenceBlock.nextSibling() as? Markdown.HTMLBlock,
				let commentBlock = HTMLCommentBlock(htmlBlock: htmlBlock),
				let errorCodeBlock = commentBlock.nextSibling() as? Markdown.CodeBlock
			else { return nil }
			return ExecutableContext.Error(
				markup: errorCodeBlock,
				header: commentBlock.commentedText,
				content: errorCodeBlock.code
			)
		}()

		return ExecutableContext(
			codeBlock: codeBlockAtLocation,
			result: result,
			error: error
		)
	}
}
