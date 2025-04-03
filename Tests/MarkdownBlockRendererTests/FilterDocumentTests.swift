import Markdown
import MarkdownBlockRenderer
import Testing

@Suite("Filtering") struct FilterDocumentTests {
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

	@Test func filteringDoesntAffectOutput() {
		/// Demonstrates that the filter closure is actually used.
		var collectedText: [String] = []
		let transformation = AnyFilterDocument(base: document) {
			let isText = $0 is Markdown.Text && !($0.parent is Markdown.Heading)
			if isText {
				collectedText.append(($0 as! Markdown.Text).string)
			}
			return isText
		}
		let result = transformation.markdown().format()
		let expected =
			"""
			# Chapter

			Text in chapter

			## Section

			Text in section

			### Subsection
			"""
		#expect(result == expected)
		#expect(collectedText == ["Text in chapter", "Text in section"])
	}
}
