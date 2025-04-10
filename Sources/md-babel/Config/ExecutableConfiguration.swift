import Foundation

/// Represents how to start an executable process, to be stored in configuration files.
struct ExecutableConfiguration {
	enum ResultMarkupType {
		case codeBlock
	}
	let executableURL: URL
	let arguments: [String]
	let resultMarkupType: ResultMarkupType
}

extension ExecutableConfiguration {
	func makeRunProcess() -> RunProcess {
		return RunProcess(
			executableURL: self.executableURL,
			defaultArguments: self.arguments
		)
	}
}
