import Markdown

extension MarkdownDocument {
	public func executableContext(at sourceLocation: Markdown.SourceLocation) -> ExecutableContext? {
		guard let codeBlockAtLocation = markup(at: sourceLocation) as? Markdown.CodeBlock else { return nil }
		let result = { () -> ExecutableContext.Result? in
			guard let metadataBlock = ResultMetadataBlock(from: codeBlockAtLocation.nextSibling())
			else { return nil }

			guard let resultBlock = metadataBlock.result(ofType: CodeBlockResult.self)
			else { return nil }

			return ExecutableContext.Result(
				metadata: metadataBlock,
				content: resultBlock
			)
		}()

		let error = { () -> ExecutableContext.Error? in
			let referenceBlock = result?.content.nextSibling() ?? codeBlockAtLocation.nextSibling()
			guard let htmlBlock = referenceBlock as? Markdown.HTMLBlock,
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
