import Markdown
import MarkdownBabel
import Testing

private func paragraph(
	_ string: String
) -> Paragraph? {
	return paragraph(through: 0, in: string)
}

private func paragraph(
	through path: Markdown.ChildIndexPath.Element...,
	in string: String
) -> Paragraph? {
	return Markdown.Document(parsing: string).child(through: path) as? Paragraph
}

@Suite("ImageParagraph") struct ImageParagraphTests {
	@Suite("parsing") struct Parsing {
		@Test(arguments: [
			"",
			"text",
			"multi\nline\ntext",
			"\tindent",
		]) func textParagraph(text: String) throws {
			let para = try #require(paragraph("Hello"))
			#expect(ImageParagraph(paragraph: para) == nil)
		}

		@Test(arguments: [
			#"before ![t](/p/ "i")"#,
			#"![t](/p/ "i") after"#,
			#"newline before\n![t](/p/ "i")"#,
			#"![t](/p/ "i")\nnewline after"#,
		]) func imageLiteralBetweenText(text: String) throws {
			let para = try #require(paragraph(text))
			#expect(ImageParagraph(paragraph: para) == nil)
		}

		@Test(arguments: [
			#" ![t](/p/ "i")"#,
			#"  ![t](/p/ "i")"#,
			#"   ![t](/p/ "i")"#,
		]) func indentedImageLiteral(text: String) throws {
			let para = try #require(paragraph(text))
			let imagePara = try #require(ImageParagraph(paragraph: para))
			#expect(imagePara.alt == "t")
			#expect(imagePara.title == "i")
			#expect(imagePara.source == "/p/")
		}

		@Test(arguments: [
			("", "", ""),

			("alt", "", ""),
			("", "", "path"),

			("alt", "", "path"),

			("", "title", "path"),

			("alt", "title", "path"),
		]) func imageLiteral(alt: String, title: String, source: String) throws {
			let titleMarkup: String = title.isEmpty ? "" : " \"\(title)\""
			let text = "![\(alt)](\(source)\(titleMarkup))"
			let para = try #require(paragraph(text))
			let imagePara = try #require(ImageParagraph(paragraph: para))
			#expect(imagePara.alt == alt)
			#expect(imagePara.title == (title.isEmpty ? nil : title))
			#expect(imagePara.source == (source.isEmpty ? nil : source))
		}

		@Test(arguments: [
			("", "title"),
			("alt", "title"),
		]) func imageLiteralWithoutPathButTitle(alt: String, title: String) throws {
			let text = "![\(alt)](\"\(title)\")"
			let para = try #require(paragraph(text))
			let imagePara = try #require(ImageParagraph(paragraph: para))
			#expect(imagePara.alt == alt)
			#expect(imagePara.title == nil)
			#expect(imagePara.source == "\"\(title)\"")
		}
	}

	@Suite("transparent visiting") struct Visiting {
		@Test("filters out non-image literal paragraph but dumps as if it's a Paragraph") func rewritingAsFilter()
			throws
		{
			struct ImageParagraphRewriter: MarkupRewriter {
				mutating func visitParagraph(_ paragraph: Paragraph) -> (any Markup)? {
					return ImageParagraph(paragraph: paragraph)
				}
			}

			let doc = Markdown.Document(
				parsing:
					"""
					Hello

					![image](/path/to/picture.svg "title")

					world
					"""
			)
			var rewriter = ImageParagraphRewriter()
			let visited = try #require(rewriter.visit(doc) as? Markdown.Document)
			let expectedDump = """
				Document
				└─ Paragraph
				   └─ Image source: "/path/to/picture.svg" title: "title"
				      └─ Text "image"
				"""
			#expect(visited.debugDescription() == expectedDump)
		}
	}
}
