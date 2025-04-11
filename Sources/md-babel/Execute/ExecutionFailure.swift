import Foundation

enum ExecutionFailure: Error, Equatable, CustomStringConvertible {
	case processExecutionFailed(String, RunProcess.TerminationStatusOrError)
	case processResultIsNotAString(Data, RunProcess.TerminationStatus)

	var description: String {
		return switch self {
		case .processExecutionFailed(let message, let statusOrError):
			"Process terminated with \(statusOrError): \(message)"
		case .processResultIsNotAString(_, let status):
			"Process terminated with non-string result (status code: \(status))"
		}
	}
}
