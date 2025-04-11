/// Response for `md-babel exec`.
public struct ExecuteResponse: Equatable, Sendable {
	/// Execution can (theoretically) finish with a result *and* error to support the document transformation of:
	///
	///     (ExecutableBlock, Result?, Error?) -> (ExecutableBlock, Result?, Error?)
	///
	/// The document may have both blocks, and the transformed result may contain both or neither.
	public struct ExecutionResult: Equatable, Sendable {
		/// - Note: `nil` will remove existing result blocks from the document during interpretation.
		public let output: String?

		/// - Note: `nil` will remove existing result blocks from the document during interpretation.
		public let error: String?

		public init(
			output: String? = nil,
			error: String? = nil
		) {
			self.output = output
			self.error = error
		}
	}

	public let executionResult: ExecutionResult

	public init(executionResult: ExecutionResult) {
		self.executionResult = executionResult
	}
}

extension ExecuteResponse.ExecutionResult {
	public static func fromRunning(
		_ block: () async throws -> String
	) async -> Self {
		do {
			let result = try await block()
			return Self(output: result, error: nil)
		} catch {
			return Self(output: nil, error: "\(error)")
		}
	}
}
