import Markdown

public struct ExecutableRegistry {
	public let codeBlockConfigurations: [String: ExecutableConfiguration]

	public init(codeBlockConfigurations: [String: ExecutableConfiguration]) {
		self.codeBlockConfigurations = codeBlockConfigurations
	}
}

extension ExecutableRegistry {
	public func configuration(
		forCodeBlock codeBlock: Markdown.CodeBlock
	) throws(ExecutableRegistryFailure) -> ExecutableConfiguration {
		guard let language = codeBlock.language
		else { throw .codeBlockWithoutLanguage }

		return try self.configuration(codeBlockWithLanguage: language)
	}

	public func configuration(
		codeBlockWithLanguage language: String
	) throws(ExecutableRegistryFailure) -> ExecutableConfiguration {
		guard let configuration = codeBlockConfigurations[language]
		else { throw .configurationMissing(codeLanguage: language) }
		return configuration
	}
}
