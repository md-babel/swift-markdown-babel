import Markdown

public protocol ResultMarkupConvertible: Markdown.Markup {
	associatedtype ResultMarkupConversion: ResultMarkup where ResultMarkupConversion.BaseMarkup == Self

	static func parsing(_ markup: any Markdown.Markup) -> Self?
}

extension Markdown.CodeBlock: ResultMarkupConvertible {
	public typealias ResultMarkupConversion = CodeBlockResult

	public static func parsing(_ markup: any Markup) -> CodeBlock? {
		return markup as? CodeBlock
	}
}

extension ImageParagraph: ResultMarkupConvertible {
	public typealias ResultMarkupConversion = ImageResult

	public static func parsing(_ markup: any Markup) -> ImageParagraph? {
		return (markup as? Markdown.Paragraph).flatMap(ImageParagraph.init(paragraph:))
	}
}
