import Markdown
import MarkdownBabel
import Testing

private func htmlBlock(
	_ string: String
) -> HTMLBlock? {
	return htmlBlock(through: 0, in: string)
}

private func htmlBlock(
	through path: Markdown.ChildIndexPath.Element...,
	in string: String
) -> HTMLBlock? {
	return Markdown.Document(parsing: string).child(through: path) as? HTMLBlock
}

@Suite("HTMLCommentBlock") struct HTMLCommentBlockTests {
	@Suite("parsing") struct Parsing {
		@Test func paragraph() throws {
			let html = try #require(htmlBlock("<p><!----></p>"))
			#expect(HTMLCommentBlock(htmlBlock: html) == nil)
		}

		@Test(arguments: [
			"<!--<!---->-->",
			"<!---->-->",
			"<!--<!---->",
		]) func nestedEmptyComments(html: String) throws {
			let html = try #require(htmlBlock(html))
			#expect(HTMLCommentBlock(htmlBlock: html) == nil)
		}

		@Test func emptyComment() throws {
			let html = try #require(htmlBlock("<!---->"))
			let comment = try #require(HTMLCommentBlock(htmlBlock: html))
			#expect(comment.commentedText == "")
		}

		@Test(arguments: [
			"<!--foo  bar-->",
			"<!--\tfoo  bar\n-->",
			" <!--  foo  bar \n --> \t ",
		]) func comment(html: String) throws {
			let html = try #require(htmlBlock(html))
			let comment = try #require(HTMLCommentBlock(htmlBlock: html))
			#expect(comment.commentedText == "foo  bar")
		}
	}

	@Suite("transparent visiting") struct Visiting {
		@Test("filters out non-comment blocks but dumps as if it's an HTMLBlock") func rewritingAsFilter() throws {
			struct CommentRewriter: MarkupRewriter {
				mutating func visitHTMLBlock(_ html: HTMLBlock) -> (any Markup)? {
					return HTMLCommentBlock(htmlBlock: html)
				}
			}

			let doc = Markdown.Document(
				parsing:
					"""
					Hello

					<!-- world -->

					or

					<p>web.</p>
					"""
			)
			var rewriter = CommentRewriter()
			let visited = try #require(rewriter.visit(doc) as? Markdown.Document)
			let expectedDump = """
				Document
				├─ Paragraph
				│  └─ Text "Hello"
				├─ HTMLBlock
				│  <!-- world -->
				└─ Paragraph
				   └─ Text "or"
				"""
			#expect(visited.debugDescription() == expectedDump)
		}
	}
}
