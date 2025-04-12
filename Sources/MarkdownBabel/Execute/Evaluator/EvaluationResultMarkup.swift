public struct UnrecognizedEvaluationResult: Error, CustomStringConvertible {
	public let type: String

	public var description: String { "Unrecognized evaluation result type: “\(type)”" }
}

/// Type of Markdown node execution result is produced to.
public enum EvaluationResultMarkup: Hashable, Sendable {

	case codeBlock

	public init(string: String) throws {
		self =
			switch string {
			case "codeBlock": .codeBlock
			default: throw UnrecognizedEvaluationResult(type: string)
			}
	}
}

extension EvaluationResultMarkup: CustomStringConvertible {
	public var description: String {
		return switch self {
		case .codeBlock: "code block"
		}
	}
}
