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

func json(_ jsonResult: ExecutableContext.Result) -> JSON {
	return [
		"range": json(jsonResult.range),
		"header": .string(jsonResult.header),
		"type": .string("code_block"),
		"language": .string(jsonResult.contentMarkup.language ?? ""),
		"content": .string(jsonResult.content),
	]
}

func json(_ markup: CodeBlock) -> JSON {
	return [
		"range": json(markup.range!),
		"type": .string("code_block"),
		"language": .string(markup.language ?? ""),
		"content": .string(markup.code),
	]
}
