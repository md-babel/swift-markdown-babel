import struct Foundation.URL

/// Represents how to start an executable process, to be stored in configuration files.
public struct ExecutableConfiguration {
	/// Type of Markdown node to apply the executable to.
	public enum ResultMarkupType: Hashable, Sendable {
		case codeBlock(language: String)

		public var key: String {
			switch self {
			case .codeBlock: "codeBlock"
			}
		}
	}

	public let executableURL: URL
	public let arguments: [String]
	public let resultMarkupType: ResultMarkupType

	public init(
		executableURL: URL,
		arguments: [String],
		resultMarkupType: ExecutableConfiguration.ResultMarkupType
	) {
		self.executableURL = executableURL
		self.arguments = arguments
		self.resultMarkupType = resultMarkupType
	}
}

extension ExecutableConfiguration.ResultMarkupType: CustomStringConvertible {
	public var description: String {
		return switch self {
		case .codeBlock(let language): "code block with language “\(language)”"
		}
	}
}
