import Markdown

extension MarkdownDocument {
	public func executableContext(at sourceLocation: Markdown.SourceLocation) -> ExecutableContext? {
		guard let codeBlockAtLocation = markup(at: sourceLocation) as? Markdown.CodeBlock
		else { return nil }

		let result = { () -> ExecutableContext.Result? in
			guard let metadataBlock = ResultMetadataBlock(from: codeBlockAtLocation.nextSibling())
			else { return nil }

			let resultBlock: (any ResultMarkup)? =
				metadataBlock.result(ofType: CodeBlockResult.self)
				?? metadataBlock.result(ofType: ImageResult.self)
			guard let resultBlock else { return nil }

			return ExecutableContext.Result(
				metadata: metadataBlock,
				content: resultBlock
			)
		}()

		let error = { () -> ExecutableContext.Error? in
			let markupBlock = result?.content.nextSibling() ?? codeBlockAtLocation.nextSibling()
			guard let metadataBlock = ErrorMetadataBlock(from: markupBlock)
			else { return nil }

			guard let errorBlock = metadataBlock.result(ofType: CodeBlockResult.self)
			else { return nil }

			return ExecutableContext.Error(
				metadata: metadataBlock,
				content: errorBlock
			)
		}()

		return ExecutableContext(
			codeBlock: codeBlockAtLocation,
			result: result,
			error: error
		)
	}
}
