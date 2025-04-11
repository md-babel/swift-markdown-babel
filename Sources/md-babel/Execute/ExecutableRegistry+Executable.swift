import Markdown
import MarkdownBabel

extension ExecutableRegistry {
	func executable(
		forCodeBlock codeBlock: Markdown.CodeBlock
	) throws(ExecutableRegistryFailure) -> Executable {
		let configuration = try configuration(forCodeBlock: codeBlock)
		return Executable(configuration: configuration)
	}
}
