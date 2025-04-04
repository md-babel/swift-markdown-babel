import Markdown
import MarkdownBlockRenderer
import Testing

@Suite struct CompactMapDocumentTests {
	@Test func mapHeadingLevelsParts() {
		let document = MarkdownDocument(
			parsing:
				"""
				# Chapter
				Text
				## Section 1
				Text
				## Section 2
				Text
				"""
		)

		let transformation = CompactMapDocument(base: document) { element -> Markdown.Heading? in
			guard var heading = element as? Markdown.Heading else { return nil }
			heading.level += 1
			return heading
		}
		let result = transformation.markdown().format()
		let expected =
			"""
			## Chapter

			Text

			### Section 1

			Text

			### Section 2

			Text
			"""
		#expect(result == expected)
	}
}
