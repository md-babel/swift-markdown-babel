import Markdown

public struct MarkdownBlockSelector<Target, Output>
where
	Target: Markdown.BlockMarkup
{
	typealias Visitor = (_ visitedBlock: Target) -> Output

	let document: Markdown.Document
	let visitor: Visitor
}
