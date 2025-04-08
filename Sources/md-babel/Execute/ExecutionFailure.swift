import Foundation

enum ExecutionFailure: Error, Equatable, CustomStringConvertible {
	case codeBlockWithoutLanguage
	case configurationMissing(codeLanguage: String)

	case processExecutionFailed(String, RunProcess.TerminationStatusOrError)
	case processResultIsNotAString(Data, RunProcess.TerminationStatus)

	var description: String {
		return switch self {
		case .codeBlockWithoutLanguage:
			"Code block doesn't have a language"
		case .configurationMissing(codeLanguage: let language):
			"Configuration missing to execute code with language “\(language)”."
		case .processExecutionFailed(let message, let statusOrError):
			"Process terminated with \(statusOrError): \(message)"
		case .processResultIsNotAString(_, let status):
			"Process terminated with non-string result (status code: \(status))"
		}
	}
}
