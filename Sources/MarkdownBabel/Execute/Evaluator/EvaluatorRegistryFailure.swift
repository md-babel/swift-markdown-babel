public enum EvaluatorRegistryFailure: Error, Sendable, CustomStringConvertible {
	case codeBlockWithoutLanguage
	case configurationMissing(ExecutableMarkup)

	public var description: String {
		return switch self {
		case .codeBlockWithoutLanguage:
			"Code block doesn't have a language"
		case .configurationMissing(let type):
			"Configuration missing to execute \(type)."
		}
	}
}
