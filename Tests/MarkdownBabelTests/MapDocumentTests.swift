import Markdown
import MarkdownBabel
import Testing

@Suite struct MapDocumentTests {
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
	let expected =
		"""
		## Chapter

		Text

		### Section 1

		Text

		### Section 2

		Text
		"""

	@Test func anyMapHeadingLevelsParts() {
		let transformation = AnyMapDocument(base: document) { element in
			guard var heading = element as? Markdown.Heading else {
				return element
			}
			heading.level += 1
			return heading
		}
		let result = transformation.markdown().format()
		#expect(result == expected)
	}
}
