// swift-format-ignore-file: AlwaysUseLowerCamelCase

import Markdown
import MarkdownBabel
import Testing

@Suite("Operator combinations:") struct OperatorCombinationTests {
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

	@Test("filter + any map") func filter_map() {
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

	@Test("compactMap + map") func compactMap_map() {
		let transformation =
			document
			.compactMap { anyElement in anyElement as? Markdown.Text }
			.map { text in Markdown.InlineCode(text.string + " is extended") }
		let result = transformation.markdown().format()
		let expected =
			"""
			# `Chapter is extended`

			`Text in chapter is extended`

			## `Section is extended`

			`Text in section is extended`

			### `Subsection is extended`
			"""
		#expect(result == expected)
	}

	@Test("compactMap + filter + map") func compactMap_filter_map() {
		let transformation =
			document
			.compactMap { anyElement in anyElement as? Markdown.Text }
			.filter { text in !(text.parent is Markdown.Heading) }
			.map { text in Markdown.InlineCode(text.string + " is extended") }
		let result = transformation.markdown().format()
		let expected =
			"""
			# Chapter

			`Text in chapter is extended`

			## Section

			`Text in section is extended`

			### Subsection
			"""
		#expect(result == expected)
	}
}
