import Markdown

public struct ExecutableContext {
	public struct Result {
		public let markup: any Markdown.Markup
		public let header: String
		public let content: String

	}

	public let codeBlock: Markdown.CodeBlock
	public let result: Result?
	public let errorCodeBlock: Markdown.CodeBlock?

	public init(
		codeBlock: CodeBlock,
		result: Result? = nil,
		errorCodeBlock: CodeBlock? = nil
	) {
		self.codeBlock = codeBlock
		self.result = result
		self.errorCodeBlock = errorCodeBlock
	}
}

extension ExecutableContext: CustomDebugStringConvertible {
	public var debugDescription: String {
		return debugDescription(options: .printSourceLocations)
	}

	public func debugDescription(options: MarkupDumpOptions = []) -> String {
		return """
			Code:
			\(codeBlock.debugDescription(options: options))
			Result:
			\(result?.debugDescription(options: options) ?? "(No Result)")
			Error:
			\(errorCodeBlock?.debugDescription(options: options)  ?? "(No Error)")
			"""
	}
}

extension ExecutableContext.Result: CustomDebugStringConvertible {
	public var debugDescription: String {
		return debugDescription(options: .printSourceLocations)
	}

	public func debugDescription(options: MarkupDumpOptions = []) -> String {
		func indent(_ string: String) -> String {
			let prefix = "  "
			return
				string
				.split(separator: "\n")
				.map { prefix + $0 }
				.joined(separator: "\n")
		}

		return """
			» Header: “\(header)”
			» Content:
			\(indent(content))
			» Markup:
			\(indent(markup.debugDescription(options: options)))
			"""
	}
}
