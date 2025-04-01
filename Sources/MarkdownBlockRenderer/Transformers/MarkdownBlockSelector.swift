import Markdown

public struct MarkdownBlockSelector<Block, Output>
where Block: Markdown.BlockMarkup {
	typealias Visitor = (_ visitedBlock: Block) -> Output

	let document: MarkdownDocument
	let recurseIntoTarget: Bool
	let visitor: Visitor
}
