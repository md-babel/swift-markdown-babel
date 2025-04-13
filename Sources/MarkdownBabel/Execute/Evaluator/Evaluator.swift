import Foundation

public struct Evaluator {
	public let configuration: EvaluatorConfiguration

	public func result(fromRunning code: String) async -> Execute.Response.ExecutionResult {
		do {
			let result = try await run(code: code)
			return .init(output: result, error: nil)
		} catch {
			return .init(output: nil, error: "\(error)")
		}
	}

	public func run(code: String) async throws -> Execute.Response.ExecutionResult.Output {
		let runProcess = configuration.makeRunProcess()
		let (result, outputData) = try await runProcess(input: code, additionalArguments: [])

		let terminationStatus: RunProcess.TerminationStatus =
			switch result {
			case .right(let error):
				throw ExecutionFailure.processExecutionFailed(error, result)
			case .left(let status):
				status
			}

		switch configuration.resultMarkupType {
		case .codeBlock:
			guard let code = String(data: outputData, encoding: .utf8)
			else { throw ExecutionFailure.processResultIsNotAString(outputData, terminationStatus) }
			return .init(
				insert: .codeBlock(language: "", code: code),
				sideEffect: nil
			)

		case .image:
			fatalError("WIP")  // FIXME: Implement image output
		}
	}
}
