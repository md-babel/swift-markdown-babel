import Markdown

extension Markdown.MarkupWalker {
	@inline(__always)
	mutating func visit(_ markdownDocument: MarkdownDocument) {
		self.visit(markdownDocument.document)
	}
}
