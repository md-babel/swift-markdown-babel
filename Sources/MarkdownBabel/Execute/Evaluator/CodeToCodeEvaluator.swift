import struct Foundation.Data
import struct Foundation.URL

public struct CodeToCodeEvaluator: Evaluator, Sendable {
	let runProcess: RunProcess
	public var executableURL: URL { runProcess.executableURL }
	public var defaultArguments: [String] { runProcess.defaultArguments }

	init(runProcess: RunProcess) {
		self.runProcess = runProcess
	}

	public func run(
		_ executableContext: ExecutableContext,
		sourceURL: URL?
	) async throws -> Execute.Response.ExecutionResult.Output {
		let code = executableContext.codeBlock.code

		// TODO: runPRocess can be throwing
		let (result, outputData) = try await runProcess(input: code, additionalArguments: [])
		let terminationStatus: RunProcess.TerminationStatus =
			switch result {
			case .right(let error):
				throw ExecutionFailure.processExecutionFailed(error, result)
			case .left(let status):
				status
			}

		guard let code = String(data: outputData, encoding: .utf8)
		else { throw ExecutionFailure.processResultIsNotAString(outputData, terminationStatus) }

		return .init(
			insert: .codeBlock(language: "", code: code),
			sideEffect: nil
		)
	}
}
