import Markdown

public protocol ResultMarkup {
	var content: String { get }

	func debugDescription(options: MarkupDumpOptions) -> String
}
