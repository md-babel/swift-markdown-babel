import struct Foundation.URL

/// Represents how to start an executable process, to be stored in configuration files.
public struct ExecutableConfiguration {
	public enum ResultMarkupType {
		case codeBlock
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
