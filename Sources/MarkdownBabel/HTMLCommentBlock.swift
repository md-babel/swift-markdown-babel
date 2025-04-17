import Markdown

/// Transparently decorates a `HTMLBlock` (to not interfere with tree traversal) to guarantee that the `HTMLBlock` consists of a single `<!--...-->` comment.
public struct HTMLCommentBlock: Markdown.BlockMarkup {
	public static let opener = "<!--"
	public static let closer = "-->"

	public var htmlBlock: HTMLBlock
	public var _data: _MarkupData {
		get { htmlBlock._data }
		set { htmlBlock._data = newValue }
	}

	public let commentedText: String

	public init(string: String) {
		let htmlBlock = Markdown.HTMLBlock("\(Self.opener)\(string)\(Self.closer)")
		guard let instance = Self(htmlBlock: htmlBlock)
		else { preconditionFailure("Programmer error; HTMLCommentBlock with <!--...--> should produce valid instance") }
		self = instance
	}

	public init?(htmlBlock: Markdown.HTMLBlock) {
		let trimmedContent = htmlBlock.rawHTML.trimmingCharacters(in: .whitespacesAndNewlines)
		guard trimmedContent.hasPrefix(HTMLCommentBlock.opener),
			trimmedContent.hasSuffix(HTMLCommentBlock.closer)
		else { return nil }

		let commentedText =
			trimmedContent
			.dropFirst(HTMLCommentBlock.opener.count)
			.dropLast(HTMLCommentBlock.closer.count)
			.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !commentedText.contains("-->"),
			!commentedText.contains("<!--")
		else { return nil }

		self.htmlBlock = htmlBlock
		self.commentedText = commentedText
	}

	public func accept<V>(_ visitor: inout V) -> V.Result where V: MarkupVisitor {
		visitor.visitHTMLBlock(htmlBlock)
	}
}
