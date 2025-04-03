import Markdown
import MarkdownBlockRenderer
import Testing

@Suite struct OperatorCombinationTests {
	let document = MarkdownDocument(
		parsing:
			"""
			# Chapter

			Text in chapter

			## Section

			Text in section

			### Subsection
			"""
	)

	@Test func filterMap() {
		let transformation =
			document
			.filter { $0 is Markdown.Text && !($0.parent is Markdown.Heading) }
			.map { _ in Markdown.Text("Redacted") }
		let result = transformation.markdown().format()
		let expected =
			"""
			# Chapter

			Redacted

			## Section

			Redacted

			### Subsection
			"""
		#expect(result == expected)
	}
}
