import Markdown

public struct ExecutableContext {
	public struct Result {
		public let range: Markdown.SourceRange
		public let header: String
		public let contentMarkup: Markdown.CodeBlock
		public var content: String { contentMarkup.code }
	}

	public struct Error {
		public let range: Markdown.SourceRange
		public let header: String
		public let contentMarkup: Markdown.CodeBlock
		public var content: String { contentMarkup.code }
	}

	public let codeBlock: Markdown.CodeBlock
	public let result: Result?
	public let error: Error?

	public init(
		codeBlock: CodeBlock,
		result: Result? = nil,
		error: Error? = nil
	) {
		self.codeBlock = codeBlock
		self.result = result
		self.error = error
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
			\(error?.debugDescription(options: options)  ?? "(No Error)")
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
			» Range: \(range)
			» Header: “\(header)”
			» Content:
			\(indent(content))
			» Content markup:
			\(indent(contentMarkup.debugDescription(options: options)))
			"""
	}
}

extension ExecutableContext.Error: CustomDebugStringConvertible {
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
			» Range: \(range)
			» Header: “\(header)”
			» Content:
			\(indent(content))
			» Content markup:
			\(indent(contentMarkup.debugDescription(options: options)))
			"""
	}
}
