import Foundation

public struct Evaluator {
	public let configuration: EvaluatorConfiguration

	public func run(code: String) async throws -> Execute.Response.ExecutionResult.Output {
		let runProcess = configuration.makeRunProcess()
		let (result, output) = try await runProcess(input: code, additionalArguments: [])

		let terminationStatus: RunProcess.TerminationStatus =
			switch result {
			case .right(let error):
				throw ExecutionFailure.processExecutionFailed(error, result)
			case .left(let status):
				status
			}

		switch configuration.resultMarkupType {
		case .codeBlock:
			switch output {
			case .data(let data):
				throw ExecutionFailure.processResultIsNotAString(data, terminationStatus)
			case .string(let code):
				return .codeBlock(language: "", code: code)
			}
		case .image:
			fatalError("WIP")  // FIXME: Implement image output
		}
	}
}
