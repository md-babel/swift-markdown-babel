import Markdown
import MarkdownBlockRenderer
import Testing

@Suite struct MapDocumentsTests {
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

		let transformation = AnyMapDocument(base: document) { element in
			guard var heading = element as? Markdown.Heading else {
				return element
			}
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
