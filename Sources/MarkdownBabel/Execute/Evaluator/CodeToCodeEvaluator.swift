import struct Foundation.Data

public struct CodeToCodeEvaluator: Evaluator, Sendable {
	public let configuration: EvaluatorConfiguration

	public init(configuration: EvaluatorConfiguration) {
		self.configuration = configuration
	}

	public func run(_ code: String) async throws -> Execute.Response.ExecutionResult.Output {
		let (terminationStatus, outputData) = try await runProcess(
			configuration: self.configuration,
			standardInput: code
		)

		guard let code = String(data: outputData, encoding: .utf8)
		else { throw ExecutionFailure.processResultIsNotAString(outputData, terminationStatus) }

		return .init(
			insert: .codeBlock(language: "", code: code),
			sideEffect: nil
		)
	}
}
