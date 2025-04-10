import Markdown

struct ExecutableRegistry {
	let codeBlockConfigurations: [String: ExecutableConfiguration]
}

extension ExecutableRegistry {
	func configuration(language: String) throws(ExecutionFailure) -> ExecutableConfiguration {
		guard let configuration = codeBlockConfigurations[language]
		else { throw .configurationMissing(codeLanguage: language) }
		return configuration
	}

	func configuration(
		forCodeBlock codeBlock: Markdown.CodeBlock
	) throws(ExecutionFailure) -> ExecutableConfiguration {
		guard let language = codeBlock.language
		else { throw .codeBlockWithoutLanguage }

		let configuration = try self.configuration(language: language)

		return configuration
	}
}

extension ExecutableRegistry {
	func executable(forCodeBlock codeBlock: Markdown.CodeBlock) throws(ExecutionFailure) -> Executable {
		let configuration = try configuration(forCodeBlock: codeBlock)
		return Executable(configuration: configuration)
	}
}
