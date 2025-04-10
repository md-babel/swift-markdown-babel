import Markdown

extension MarkdownDocument {
	public func executableContext(at sourceLocation: Markdown.SourceLocation) -> ExecutableContext? {
		guard let codeBlockAtLocation = markup(at: sourceLocation) as? Markdown.CodeBlock else { return nil }
		let result = { () -> ExecutableContext.Result? in
			guard let htmlBlock = codeBlockAtLocation.nextSibling() as? Markdown.HTMLBlock,
				let commentBlock = HTMLCommentBlock(htmlBlock: htmlBlock),
				let commentBlockRange = commentBlock.range,
				commentBlock.commentedText.hasPrefix("Result:"),
				let resultCodeBlock = commentBlock.nextSibling() as? Markdown.CodeBlock,
				let resultCodeBlockRange = resultCodeBlock.range
			else { return nil }
			return ExecutableContext.Result(
				range: commentBlockRange.lowerBound..<resultCodeBlockRange.upperBound,
				header: commentBlock.commentedText,
				contentMarkup: resultCodeBlock
			)
		}()
		let error = { () -> ExecutableContext.Error? in
			let referenceBlock = result?.contentMarkup ?? codeBlockAtLocation
			guard let htmlBlock = referenceBlock.nextSibling() as? Markdown.HTMLBlock,
				let commentBlock = HTMLCommentBlock(htmlBlock: htmlBlock),
				let commentBlockRange = commentBlock.range,
				commentBlock.commentedText.hasPrefix("Error:"),
				let errorCodeBlock = commentBlock.nextSibling() as? Markdown.CodeBlock,
				let errorCodeBlockRange = errorCodeBlock.range
			else { return nil }
			return ExecutableContext.Error(
				range: commentBlockRange.lowerBound..<errorCodeBlockRange.upperBound,
				header: commentBlock.commentedText,
				contentMarkup: errorCodeBlock
			)
		}()

		return ExecutableContext(
			codeBlock: codeBlockAtLocation,
			result: result,
			error: error
		)
	}
}
