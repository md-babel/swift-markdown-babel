extension ExecutableConfiguration {
	func makeRunProcess() -> RunProcess {
		return RunProcess(
			executableURL: self.executableURL,
			defaultArguments: self.arguments
		)
	}
}
