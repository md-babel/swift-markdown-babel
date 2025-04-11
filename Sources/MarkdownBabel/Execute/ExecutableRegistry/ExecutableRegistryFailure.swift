public enum ExecutableRegistryFailure: Error, Sendable, CustomStringConvertible {
	case codeBlockWithoutLanguage
	case configurationMissing(codeLanguage: String)

	public var description: String {
		return switch self {
		case .codeBlockWithoutLanguage:
			"Code block doesn't have a language"
		case .configurationMissing(codeLanguage: let language):
			"Configuration missing to execute code with language “\(language)”."
		}
	}
}
