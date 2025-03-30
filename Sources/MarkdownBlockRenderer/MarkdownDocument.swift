import Foundation
import Markdown

public struct MarkdownDocument {
	let document: Markdown.Document

	public init(parsing url: URL) throws {
		self.document = try .init(parsing: url)
	}

	public init(parsing string: String) {
		self.document = .init(parsing: string)
	}
}
