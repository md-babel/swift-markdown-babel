/// Type of Markdown node to apply the executable to.
public enum ExecutableMarkup: Hashable, Sendable {
	case codeBlock(language: String)
	// case table

	public var key: String {
		switch self {
		case .codeBlock: "codeBlock"
		}
	}
}

extension ExecutableMarkup: CustomStringConvertible {
	public var description: String {
		return switch self {
		case .codeBlock(let language): "code block with language “\(language)”"
		}
	}
}
