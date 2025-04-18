import Markdown

/// Represents the comment-based header or metadata parts of a result or error block.
public struct ResultMetadataBlock {
	public static let headerPrefix = "Result:"

	let commentBlock: DocumentEmbedded<HTMLCommentBlock>
	public var header: String { commentBlock.markup.commentedText }
	public var range: SourceRange { commentBlock.range }

	/// Associated result block that follows immediately on the metadata block.
	func result<R>(ofType: R.Type) -> R?
	where R: ResultMarkup {
		guard let nextSibling = commentBlock.markup.nextSibling() as? R.BaseMarkup,
			let nextEmbedded = nextSibling.embedded()
		else { return nil }
		return nextEmbedded.makeResultMarkup()
	}
}

extension ResultMetadataBlock {
	init?(from markup: Markdown.Markup) {
		guard let htmlBlock = markup as? Markdown.HTMLBlock,
			let commentBlock = HTMLCommentBlock(htmlBlock: htmlBlock),
			let embedded = DocumentEmbedded(commentBlock),
			embedded.markup.commentedText.hasPrefix(Self.headerPrefix)
		else { return nil }
		self.init(commentBlock: embedded)
	}

	@_disfavoredOverload
	init?(from markup: Markdown.Markup?) {
		guard let markup else { return nil }
		self.init(from: markup)
	}
}

extension ResultMetadataBlock {
	static func makeHTMLCommentBlock() -> HTMLCommentBlock {
		return HTMLCommentBlock(string: headerPrefix)
	}
}
