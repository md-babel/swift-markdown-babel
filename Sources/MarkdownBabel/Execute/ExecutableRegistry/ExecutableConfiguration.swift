import struct Foundation.URL

/// Type of Markdown node to apply the executable to.
public enum ExecutableMarkupType: Hashable, Sendable {
	case codeBlock(language: String)
	// case table

	public var key: String {
		switch self {
		case .codeBlock: "codeBlock"
		}
	}
}

/// Represents how to start an executable process, to be stored in configuration files.
public struct ExecutableConfiguration {
	public let executableURL: URL
	public let arguments: [String]
	public let executableMarkupType: ExecutableMarkupType

	public init(
		executableURL: URL,
		arguments: [String],
		executableMarkupType: ExecutableMarkupType
	) {
		self.executableURL = executableURL
		self.arguments = arguments
		self.executableMarkupType = executableMarkupType
	}
}

extension ExecutableMarkupType: CustomStringConvertible {
	public var description: String {
		return switch self {
		case .codeBlock(let language): "code block with language “\(language)”"
		}
	}
}
