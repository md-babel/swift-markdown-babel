import Markdown

/// Transparently decorates a `Paragraph` (to not interfere with tree traversal) to guarantee that it only contains an `Image` literal.
///
/// - Note: Custom `Markup` types cannot actually be inserted into the AST as of swift-markdown v0.6.0 (2025-04-19) because of the private raw markup data and built-in type conversion. The `Markup` conformance is merely convenience.
public struct ImageParagraph: Markdown.BlockMarkup {
	public private(set) var paragraph: Markdown.Paragraph
	public let image: Markdown.Image
	public var _data: Markdown._MarkupData {
		get { paragraph._data }
		set { preconditionFailure("Changing ImageParagraph._data undefined (would require reparsing the paragraph)") }
	}

	public var title: String? { image.title }
	public var source: String? { image.source }
	public let alt: String

	public init?(paragraph: Markdown.Paragraph) {
		guard paragraph.childCount == 1,
			let image = paragraph.child(at: 0) as? Markdown.Image
		else { return nil }
		self.paragraph = paragraph
		self.image = image
		self.alt = image.plainText
	}

	public func accept<V>(_ visitor: inout V) -> V.Result where V: MarkupVisitor {
		visitor.visitParagraph(paragraph)
	}
}
