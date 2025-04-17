import Markdown

// TODO: Make ExecutableContext sendable https://github.com/md-babel/swift-markdown-babel/issues/21
public struct ExecutableContext {
	public struct Result {
		public let range: Markdown.SourceRange
		public let header: String
		private let contentMarkup: Markdown.CodeBlock
		public var language: String { contentMarkup.language ?? "" }
		public var content: String { contentMarkup.code }

		internal init(range: SourceRange, header: String, contentMarkup: CodeBlock) {
			self.range = range
			self.header = header
			self.contentMarkup = contentMarkup
		}
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

	public var encompassingRange: Markdown.SourceRange {
		let codeBlockRange = codeBlock.range!
		let lowerBound = codeBlockRange.lowerBound
		let upperBound = max(
			(result?.range.upperBound ?? codeBlockRange.upperBound),
			(error?.range.upperBound ?? codeBlockRange.upperBound),
			codeBlockRange.upperBound
		)
		return lowerBound..<upperBound
	}

	public init(
		codeBlock: CodeBlock,
		result: Result? = nil,
		error: Error? = nil
	) {
		precondition(codeBlock.range != nil, "CodeBlock needs to come from a document and have a range")
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
