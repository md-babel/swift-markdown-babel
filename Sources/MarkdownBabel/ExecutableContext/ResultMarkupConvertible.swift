import Markdown

protocol ResultMarkupConvertible {
	associatedtype Conversion: ResultMarkup
	func makeResultMarkup() -> Conversion
}

extension Markdown.CodeBlock: ResultMarkupConvertible {
	func makeResultMarkup() -> CodeBlockResult {
		return CodeBlockResult(markdown: self)
	}
}

extension Markdown.Image: ResultMarkupConvertible {
	func makeResultMarkup() -> ImageResult {
		return ImageResult(markdown: self)
	}
}
