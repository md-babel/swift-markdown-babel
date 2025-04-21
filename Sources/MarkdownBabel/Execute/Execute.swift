import struct Foundation.URL

public struct Execute {
	let executableContext: ExecutableContext
	let evaluator: any Evaluator

	public init(
		executableContext: ExecutableContext,
		evaluator: any Evaluator
	) {
		self.executableContext = executableContext
		self.evaluator = evaluator
	}

	@inlinable @inline(__always)
	public func callAsFunction(sourceURL: URL?) async -> Response {
		return await execute(sourceURL: sourceURL)
	}

	public func execute(sourceURL: URL?) async -> Response {
		let result: Execute.Response.ExecutionResult
		do {
			let output = try await evaluator.run(executableContext, sourceURL: sourceURL)
			result = .init(output: output, error: nil)
		} catch {
			result = .init(output: nil, error: "\(error)")
		}

		return Response(
			executableContext: executableContext,
			executionResult: result
		)
	}
}
