public enum ExecutableRegistryFailure: Error, Sendable, CustomStringConvertible {
	case codeBlockWithoutLanguage
	case configurationMissing(ExecutableConfiguration.ResultMarkupType)

	public var description: String {
		return switch self {
		case .codeBlockWithoutLanguage:
			"Code block doesn't have a language"
		case .configurationMissing(let type):
			"Configuration missing to execute \(type)."
		}
	}
}
