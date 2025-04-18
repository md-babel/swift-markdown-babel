import DynamicJSON
import Markdown
import MarkdownBabel

func json(_ location: SourceLocation) -> JSON {
	return [
		"line": .integer(Int64(location.line)),
		"column": .integer(Int64(location.column)),
	]
}

func json(_ range: SourceRange) -> JSON {
	return [
		"from": json(range.lowerBound),
		"to": json(range.upperBound),
	]
}

func json(_ error: ExecutableContext.Error) -> JSON {
	return [
		"range": json(error.range),
		"header": .string(error.header),
		"type": .string("code_block"),
		"language": .string(error.contentMarkup.language ?? ""),
		"content": .string(error.content),
	]
}

func json(_ codeBlock: CodeBlockResult) -> JSON {
	return [
		"type": .string("code_block"),
		"language": .string(codeBlock.language),
		"content": .string(codeBlock.code),
	]
}

func json(_ anyResultMarkup: any ResultMarkup) -> JSON {
	return switch anyResultMarkup {
	case let codeBlock as CodeBlockResult: json(codeBlock)
	default: fatalError("Unhandled result markup type \(type(of: anyResultMarkup))")
	}
}

func json(_ jsonResult: ExecutableContext.Result) -> JSON {
	let result: JSON = [
		"range": json(jsonResult.encompassingRange),
		"header": .string(jsonResult.metadata.header),
	]
	return result.merging(patch: json(jsonResult.content))
}

func json(_ markup: CodeBlock) -> JSON {
	return [
		"range": json(markup.range!),
		"type": .string("code_block"),
		"language": .string(markup.language ?? ""),
		"content": .string(markup.code),
	]
}
