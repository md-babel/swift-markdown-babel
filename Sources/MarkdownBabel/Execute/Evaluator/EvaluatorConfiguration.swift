import struct Foundation.URL

/// Represents how to start an executable process to evaluate code blocks.
///
/// These are usually hydrated from configuration files. See ``EvaluatorRegistry``.
public struct EvaluatorConfiguration: Equatable, Sendable {
	/// Path to the program to execute during evaluation.
	public let executableURL: URL
	/// Command-line arguments to pass to the program during evaluation.
	public let arguments: [String]

	/// Type of the source block to evaluate.
	public let executableMarkupType: ExecutableMarkup
	/// Type of the output to produce.
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

extension EvaluatorConfiguration {
	public func makeEvaluator(
		outputDirectory: URL
	) -> any Evaluator {
		switch (self.executableMarkupType, self.resultMarkupType) {
		case (.codeBlock, .codeBlock):
			return CodeToCodeEvaluator(runProcess: self.makeRunProcess())
		case (.codeBlock, .image(let imageConfiguration)):
			return CodeToImageEvaluator(
				runProcess: self.makeRunProcess(),
				imageConfiguration: imageConfiguration,
				generateImageFileURL: GenerateImageFileURL(
					outputDirectory: outputDirectory
				)
			)
		}
	}
}
