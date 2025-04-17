import Markdown

public struct CodeBlockResult: ResultMarkup {
	let _debugDescription: (_ options: MarkupDumpOptions) -> String

	public let language: String
	public let code: String
	public var content: String { code }

	public init(markdown codeBlock: Markdown.CodeBlock) {
		self.language = codeBlock.language ?? ""
		self.code = codeBlock.code
		self._debugDescription = { codeBlock.debugDescription(options: $0) }
	}

	public func debugDescription(options: MarkupDumpOptions = []) -> String {
		return _debugDescription(options)
	}
}
