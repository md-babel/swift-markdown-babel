public struct Execute {
	let executableContext: ExecutableContext
	let evaluator: Evaluator

	public init(
		executableContext: ExecutableContext,
		evaluator: Evaluator
	) {
		self.executableContext = executableContext
		self.evaluator = evaluator
	}

	public init(
		executableContext: ExecutableContext,
		registry: EvaluatorRegistry
	) throws(EvaluatorRegistryFailure) {
		self.init(
			executableContext: executableContext,
			evaluator: try registry.evaluator(forCodeBlock: executableContext.codeBlock)
		)
	}

	@inlinable @inline(__always)
	public func callAsFunction() async -> Response {
		return await execute()
	}

	public func execute() async -> Response {
		let result = await Response.ExecutionResult.fromRunning {
			return try await evaluator.run(code: executableContext.codeBlock.code)
		}
		return Response(
			executableContext: executableContext,
			executionResult: result
		)
	}
}
