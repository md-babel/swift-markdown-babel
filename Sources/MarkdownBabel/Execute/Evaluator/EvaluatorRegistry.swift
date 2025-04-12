import Markdown

public struct EvaluatorRegistry {
	public typealias Configurations = [ExecutableMarkup: EvaluatorConfiguration]

	public let configurations: Configurations

	public init(configurations: Configurations) {
		self.configurations = configurations
	}
}

extension EvaluatorRegistry {
	@inlinable
	public func configuration(
		forCodeBlock codeBlock: Markdown.CodeBlock
	) throws(EvaluatorRegistryFailure) -> EvaluatorConfiguration {
		guard let language = codeBlock.language
		else { throw .codeBlockWithoutLanguage }
		return try self.configuration(codeBlockWithLanguage: language)
	}

	@inlinable
	public func configuration(
		codeBlockWithLanguage language: String
	) throws(EvaluatorRegistryFailure) -> EvaluatorConfiguration {
		return try configuration(.codeBlock(language: language))
	}

	public func configuration(
		_ type: ExecutableMarkup
	) throws(EvaluatorRegistryFailure) -> EvaluatorConfiguration {
		guard let configuration = configurations[type]
		else { throw .configurationMissing(type) }
		return configuration
	}
}
