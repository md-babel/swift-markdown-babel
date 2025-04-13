import struct Foundation.Data
import struct Foundation.URL

extension Execute {
	/// Response for `md-babel exec`.
	public struct Response {
		/// Execution can (theoretically) finish with a result *and* error to support the document transformation of:
		///
		///     (ExecutableBlock, Result?, Error?) -> (ExecutableBlock, Result?, Error?)
		///
		/// The document may have both blocks, and the transformed result may contain both or neither.
		public struct ExecutionResult: Equatable {
			public enum Insert: Equatable {
				case codeBlock(language: String, code: String)

				public var stringContent: String {
					return switch self {
					case .codeBlock(language: _, let code): code.trimmingCharacters(in: .newlines)
					}
				}
			}

			public enum SideEffect: Equatable {
				case writeFile(Data, URL)
			}

			public struct Output: Equatable {
				public let insert: Insert
				public let sideEffect: SideEffect?

				public init(
					insert: Execute.Response.ExecutionResult.Insert,
					sideEffect: Execute.Response.ExecutionResult.SideEffect? = nil
				) {
					self.insert = insert
					self.sideEffect = sideEffect
				}
			}

			/// - Note: `nil` will remove existing result blocks from the document during interpretation.
			public let output: Output?

			/// - Note: `nil` will remove existing result blocks from the document during interpretation.
			public let error: String?

			public init(
				output: Output? = nil,
				error: String? = nil
			) {
				self.output = output
				self.error = error
			}
		}

		public let executableContext: ExecutableContext
		public let executionResult: ExecutionResult

		public init(
			executableContext: ExecutableContext,
			executionResult: ExecutionResult
		) {
			self.executableContext = executableContext
			self.executionResult = executionResult
		}
	}
}
