import Foundation
import Markdown

public struct MarkdownDocument {
	public let string: String
	public let document: Markdown.Document
	public let sourceURL: URL?

	public init(
		parsing url: URL
	) throws {
		let string = try String(contentsOf: url)
		self.init(parsing: string, sourceURL: nil)
	}

	public init(
		parsing string: String,
		sourceURL: URL? = nil
	) {
		self.sourceURL = sourceURL
		self.string = string
		self.document = .init(parsing: string)
	}
}

extension MarkdownDocument {
	public func debugDescription(options: Markdown.MarkupDumpOptions = []) -> String {
		return document.debugDescription(options: options)
	}
}
