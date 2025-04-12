import Markdown

public struct ExecutableRegistry {
	public typealias Configurations = [ExecutableMarkup: ExecutableConfiguration]

	public let configurations: Configurations

	public init(configurations: Configurations) {
		self.configurations = configurations
	}
}

extension ExecutableRegistry {
	@inlinable
	public func configuration(
		forCodeBlock codeBlock: Markdown.CodeBlock
	) throws(ExecutableRegistryFailure) -> ExecutableConfiguration {
		guard let language = codeBlock.language
		else { throw .codeBlockWithoutLanguage }
		return try self.configuration(codeBlockWithLanguage: language)
	}

	@inlinable
	public func configuration(
		codeBlockWithLanguage language: String
	) throws(ExecutableRegistryFailure) -> ExecutableConfiguration {
		return try configuration(.codeBlock(language: language))
	}

	public func configuration(
		_ type: ExecutableMarkup
	) throws(ExecutableRegistryFailure) -> ExecutableConfiguration {
		guard let configuration = configurations[type]
		else { throw .configurationMissing(type) }
		return configuration
	}
}
