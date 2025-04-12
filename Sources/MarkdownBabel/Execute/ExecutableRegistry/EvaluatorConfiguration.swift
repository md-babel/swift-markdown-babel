import struct Foundation.URL

/// Represents how to start an executable process to evaluate code blocks.
///
/// These are usually hydrated from configuration files. See ``ExecutableRegistry``.
public struct EvaluatorConfiguration: Equatable, Sendable {
	public let executableURL: URL
	public let arguments: [String]
	public let executableMarkupType: ExecutableMarkup
	public let resultMarkupType: EvaluationResultMarkup

	public init(
		executableURL: URL,
		arguments: [String],
		executableMarkupType: ExecutableMarkup,
		resultMarkupType: EvaluationResultMarkup
	) {
		self.executableURL = executableURL
		self.arguments = arguments
		self.executableMarkupType = executableMarkupType
		self.resultMarkupType = resultMarkupType
	}
}

extension EvaluatorConfiguration {
	public init(
		executablePath: String,
		arguments: [String],
		executableMarkupType: ExecutableMarkup,
		resultMarkupType: EvaluationResultMarkup
	) {
		self.init(
			executableURL: URL(filePath: executablePath),
			arguments: arguments,
			executableMarkupType: executableMarkupType,
			resultMarkupType: resultMarkupType
		)
	}
}
