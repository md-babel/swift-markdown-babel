import Markdown

struct ExecutableRegistry {
	let configurations: [String: ExecutableConfiguration]
}

extension ExecutableRegistry {
	func configuration(language: String) throws(ExecutionFailure) -> ExecutableConfiguration? {
		return configurations[language]
	}

	func configuration(forCodeBlock codeBlock: Markdown.CodeBlock) throws(ExecutionFailure) -> ExecutableConfiguration {
		guard let language = codeBlock.language
		else { throw .codeBlockWithoutLanguage }

		guard let configuration = try self.configuration(language: language)
		else { throw .configurationMissing(codeLanguage: language) }

		return configuration
	}
}

extension ExecutableRegistry {
	func executable(forCodeBlock codeBlock: Markdown.CodeBlock) throws(ExecutionFailure) -> Executable {
		let configuration = try configuration(forCodeBlock: codeBlock)
		return Executable(configuration: configuration)
	}
}
