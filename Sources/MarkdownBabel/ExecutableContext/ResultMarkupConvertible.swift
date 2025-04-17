import Markdown

public protocol ResultMarkupConvertible: Markdown.Markup {
	associatedtype ResultMarkupConversion: ResultMarkup where ResultMarkupConversion.BaseMarkup == Self
}

extension Markdown.CodeBlock: ResultMarkupConvertible {
	public typealias ResultMarkupConversion = CodeBlockResult
}

extension Markdown.Image: ResultMarkupConvertible {
	public typealias ResultMarkupConversion = ImageResult
}
