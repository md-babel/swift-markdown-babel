import Markdown

public struct ExecutableRegistry {
	public typealias Configurations = [ExecutableMarkup: EvaluatorConfiguration]

	public let configurations: Configurations

	public init(configurations: Configurations) {
		self.configurations = configurations
	}
}

extension ExecutableRegistry {
	@inlinable
	public func configuration(
		forCodeBlock codeBlock: Markdown.CodeBlock
	) throws(ExecutableRegistryFailure) -> EvaluatorConfiguration {
		guard let language = codeBlock.language
		else { throw .codeBlockWithoutLanguage }
		return try self.configuration(codeBlockWithLanguage: language)
	}

	@inlinable
	public func configuration(
		codeBlockWithLanguage language: String
	) throws(ExecutableRegistryFailure) -> EvaluatorConfiguration {
		return try configuration(.codeBlock(language: language))
	}

	public func configuration(
		_ type: ExecutableMarkup
	) throws(ExecutableRegistryFailure) -> EvaluatorConfiguration {
		guard let configuration = configurations[type]
		else { throw .configurationMissing(type) }
		return configuration
	}
}
