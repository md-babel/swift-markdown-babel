import Markdown
import MarkdownBabel
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

	@Test func anyFilterDoesntAffectOutput() {
		/// Demonstrates that the filter closure is actually used.
		var collectedTexts: [String] = []
		let transformation = AnyFilterDocument(base: document) {
			let isText = $0 is Markdown.Text && !($0.parent is Markdown.Heading)
			if isText {
				collectedTexts.append(($0 as! Markdown.Text).string)
			}
			return isText
		}
		let result =
			transformation
			.markdown(visitor: { $0 })  // Apply downstream visitor to avoid optimizing the filter away completely. Without this, `collectedTexts` would be empty.
			.markdown()
			.format()
		let expected =
			"""
			# Chapter

			Text in chapter

			## Section

			Text in section

			### Subsection
			"""
		#expect(result == expected)
		#expect(collectedTexts == ["Text in chapter", "Text in section"])
	}

	@Test func typedFilterDoesntAffectOutput() {
		/// Demonstrates that the filter closure is actually used.
		var collectedTexts: [String] = []
		let transformation = FilterDocument(base: document) { (text: Markdown.Text) -> Bool in
			guard !(text.parent is Markdown.Heading)
			else { return false }
			collectedTexts.append(text.string)
			return true
		}
		let result =
			transformation
			.markdown(visitor: { $0 })  // Apply downstream visitor to avoid optimizing the filter away completely. Without this, `collectedTexts` would be empty.
			.markdown()
			.format()
		let expected =
			"""
			# Chapter

			Text in chapter

			## Section

			Text in section

			### Subsection
			"""
		#expect(result == expected)
		#expect(collectedTexts == ["Text in chapter", "Text in section"])
	}
}
