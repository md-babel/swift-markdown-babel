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
		_ executableContext: ExecutableContext
	) async throws -> Execute.Response.ExecutionResult.Output {
		let code = executableContext.codeBlock.code

		let (terminationStatus, outputData) = try await runProcess(input: code, additionalArguments: [])

		guard let code = String(data: outputData, encoding: .utf8)
		else { throw ExecutionFailure.processResultIsNotAString(outputData, terminationStatus) }

		return .init(
			insert: .codeBlock(language: "", code: code),
			sideEffect: nil
		)
	}
}
