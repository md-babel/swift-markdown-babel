import Markdown

public protocol MetadataBlockType {
	static var headerPrefix: String { get }
}

public enum ResultBlock: MetadataBlockType {
	public static let headerPrefix = "Result:"
}

public enum ErrorBlock: MetadataBlockType {
	public static let headerPrefix = "Error:"
}

public typealias ResultMetadataBlock = MetadataBlock<ResultBlock>
public typealias ErrorMetadataBlock = MetadataBlock<ErrorBlock>

/// The HTML comment-based header (or metadata parts) of a result or error block.
public struct MetadataBlock<T>
where T: MetadataBlockType {
	public static var headerPrefix: String { T.headerPrefix }

	let commentBlock: DocumentEmbedded<HTMLCommentBlock>
	public var header: String { commentBlock.markup.commentedText }
	public var range: SourceRange { commentBlock.range }

	/// Associated result block that follows immediately on the metadata block.
	func result<R>(ofType: R.Type) -> R?
	where R: ResultMarkup {
		guard let nextSibling = commentBlock.nextSibling(parsing: R.BaseMarkup.parsing(_:)),
			let nextEmbedded = nextSibling.embedded()
		else { return nil }
		return nextEmbedded.makeResultMarkup()
	}
}

extension DocumentEmbedded {
	func nextSibling<T>(parsing: (any Markdown.Markup) -> T?) -> T?
	where T: Markdown.Markup {
		guard let next = self.nextSibling() else { return nil }
		return parsing(next)
	}
}

extension MetadataBlock {
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

extension MetadataBlock {
	static func makeHTMLCommentBlock() -> HTMLCommentBlock {
		return HTMLCommentBlock(string: headerPrefix)
	}
}
