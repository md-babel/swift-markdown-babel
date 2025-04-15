public struct UnrecognizedEvaluationResult: Error, CustomStringConvertible {
	public let type: Either<String, [String: String]>

	public var description: String { "Unrecognized evaluation result type: “\(type)”" }
}

/// Type of Markdown node execution result is produced to.
public enum EvaluationResultMarkup: Hashable, Sendable {
	case codeBlock
	case image(ImageEvaluationConfiguration)

	public static func image(
		fileExtension: String,
		directory: String,
		filenamePattern: String
	) -> EvaluationResultMarkup {
		return .image(.init(fileExtension: fileExtension, directory: directory, filenamePattern: filenamePattern))
	}
}

extension EvaluationResultMarkup: CustomStringConvertible {
	public var description: String {
		return switch self {
		case .codeBlock:
			"code block"
		case .image(let config):
			"image (\(config.directory)/\(config.filenamePattern).\(config.fileExtension))"
		}
	}
}
