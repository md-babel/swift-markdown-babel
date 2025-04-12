import struct Foundation.URL

/// Represents how to start an executable process, to be stored in configuration files.
public struct ExecutableConfiguration {
	public let executableURL: URL
	public let arguments: [String]
	public let executableMarkupType: ExecutableMarkup

	public init(
		executableURL: URL,
		arguments: [String],
		executableMarkupType: ExecutableMarkup
	) {
		self.executableURL = executableURL
		self.arguments = arguments
		self.executableMarkupType = executableMarkupType
	}
}
