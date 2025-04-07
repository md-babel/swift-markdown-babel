import Markdown

public struct ExecutableContext: CustomDebugStringConvertible {
	public let codeBlock: Markdown.CodeBlock
	public let resultCodeBlock: Markdown.CodeBlock?
	public let errorCodeBlock: Markdown.CodeBlock?

	public init(
		codeBlock: CodeBlock,
		resultCodeBlock: CodeBlock? = nil,
		errorCodeBlock: CodeBlock? = nil
	) {
		self.codeBlock = codeBlock
		self.resultCodeBlock = resultCodeBlock
		self.errorCodeBlock = errorCodeBlock
	}

	public var debugDescription: String {
		return debugDescription(options: .printSourceLocations)
	}

	public func debugDescription(options: MarkupDumpOptions = []) -> String {
		return """
			Code:
			\(codeBlock.debugDescription(options: options))
			Result:
			\(resultCodeBlock?.debugDescription(options: options) ?? "(No Result)")
			Error:
			\(errorCodeBlock?.debugDescription(options: options)  ?? "(No Error)")
			"""
	}
}
