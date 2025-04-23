import struct Foundation.Data
import struct Foundation.URL

public protocol Evaluator: Sendable {
	func run(
		_ executableContext: ExecutableContext,
		sourceURL: URL?
	) async throws -> Execute.Response.ExecutionResult.Output
}
