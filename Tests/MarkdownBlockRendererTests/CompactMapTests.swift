import Markdown
import MarkdownBlockRenderer
import Testing

@Suite struct CompactMapsTests {
	let even = { (num: Int) -> Int? in
		num % 2 == 0 ? num : nil
	}

	@Test func compactMapJustOneValue_TransformationReturnsNil() {
		let compactMap = CompactMap(from: Just(3), transform: even)
		var results: [Int] = []
		compactMap.do { results.append($0) }
		#expect(results == [])
	}

	@Test func compactMapJustOneValue_TransformationReturnsValue() {
		let compactMap = CompactMap(from: Just(2), transform: even)
		var results: [Int] = []
		compactMap.do { results.append($0) }
		#expect(results == [2])
	}

	@Test func mapDocumentParts() {
		let document = MarkdownDocument(
			parsing:
				"""
				# Chapter
				Text
				## Section
				Text
				### Subsection
				"""
		)
		let compactMap =
			document
			.compactMap { $0 as? Markdown.Heading }
			.map { heading in
				"\(heading.level): \((heading.child(at: 0) as! Markdown.Text).string)"
			}
		var results: [String] = []
		compactMap.do { results.append($0) }
		#expect(
			results == [
				"1: Chapter",
				"2: Section",
				"3: Subsection",
			]
		)
	}
}
