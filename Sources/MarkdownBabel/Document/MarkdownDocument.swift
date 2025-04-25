import Foundation
import Markdown

public struct MarkdownDocument {
	public let string: String
	public let document: Markdown.Document
	public let file: File

	public init(
		parsing url: URL
	) throws {
		let string = try String(contentsOf: url)
		self.init(
			parsing: string,
			file: File(sourceURL: url)
		)
	}

	public init(
		parsing string: String
	) {
		self.init(parsing: string, file: .standardInput)
	}

	public init(
		parsing string: String,
		file: File
	) {
		self.file = file
		self.string = string
		self.document = .init(parsing: string)
	}
}

extension MarkdownDocument {
	public func debugDescription(options: Markdown.MarkupDumpOptions = []) -> String {
		return document.debugDescription(options: options)
	}
}
