import Markdown

public struct ImageResult: ResultMarkup {
	let _debugDescription: (_ options: MarkupDumpOptions) -> String

	public let title: String
	public let source: String
	public var content: String { source }

	public init(markdown image: Markdown.Image) {
		self.title = image.title ?? ""
		self.source = image.source ?? ""
		self._debugDescription = { image.debugDescription(options: $0) }
	}

	public func debugDescription(options: MarkupDumpOptions = []) -> String {
		return _debugDescription(options)
	}
}
