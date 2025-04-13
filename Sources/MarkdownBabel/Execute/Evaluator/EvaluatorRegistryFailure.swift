public enum EvaluatorRegistryFailure: Error, Sendable, CustomStringConvertible {
	case codeBlockWithoutLanguage
	case configurationMissing(ExecutableMarkup)
	case directoryLookupFailed(String)

	public var description: String {
		return switch self {
		case .codeBlockWithoutLanguage:
			"Code block doesn't have a language"
		case .configurationMissing(let type):
			"Configuration missing to execute \(type)."
		case .directoryLookupFailed(let message):
			"Directory lookup failed: \(message)"
		}
	}
}
