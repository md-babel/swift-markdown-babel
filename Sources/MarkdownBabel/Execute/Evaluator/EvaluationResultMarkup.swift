public struct UnrecognizedEvaluationResult: Error, CustomStringConvertible {
	public let type: Either<String, [String: String]>

	public var description: String { "Unrecognized evaluation result type: “\(type)”" }
}

/// Type of Markdown node execution result is produced to.
public enum EvaluationResultMarkup: Hashable, Sendable {
	case codeBlock
	case image(fileExtension: String, directory: String, filenamePattern: String)
}

extension EvaluationResultMarkup: CustomStringConvertible {
	public var description: String {
		return switch self {
		case .codeBlock:
			"code block"
		case .image(let fileExtension, let directory, filenamePattern: let pattern):
			"image (\(directory)/\(pattern).\(fileExtension))"
		}
	}
}
