import struct Foundation.Data

public protocol Evaluator: Sendable {
	func run(_ input: String) async throws -> Execute.Response.ExecutionResult.Output
}

extension Evaluator {
	func runProcess(
		configuration: EvaluatorConfiguration,
		standardInput: String
	) async throws -> (RunProcess.TerminationStatus, Data) {
		let runProcess = configuration.makeRunProcess()
		let (result, outputData) = try await runProcess(input: standardInput, additionalArguments: [])
		let terminationStatus: RunProcess.TerminationStatus =
			switch result {
			case .right(let error):
				throw ExecutionFailure.processExecutionFailed(error, result)
			case .left(let status):
				status
			}
		return (terminationStatus, outputData)
	}
}
