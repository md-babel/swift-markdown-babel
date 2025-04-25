import struct Foundation.Data
import struct Foundation.URL

public protocol Evaluator: Sendable {
	func run(
		_ executableContext: ExecutableContext
	) async throws -> Execute.Response.ExecutionResult.Output
}
