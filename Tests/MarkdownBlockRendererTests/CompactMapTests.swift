import Markdown
import MarkdownBlockRenderer
import Testing

@Suite("Compact Mapping") struct CompactMapsTests {
	@Suite("just one value") struct JustOneValue {
		let even = { (num: Int) -> Int? in
			num % 2 == 0 ? num : nil
		}

		@Test func transformationReturnsNil() {
			let compactMap = CompactMap(from: Just(3), transform: even)
			var results: [Int] = []
			compactMap.do { results.append($0) }
			#expect(results == [])
		}

		@Test func transformationReturnsValue() {
			let compactMap = CompactMap(from: Just(2), transform: even)
			var results: [Int] = []
			compactMap.do { results.append($0) }
			#expect(results == [2])
		}
	}

	@Suite("on document") struct OnDocument {
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

		@Test("via forEach") func forEachDocumentPart() {
			let compactMap =
				document
				.forEach(Markdown.Heading.self)
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

		@Test("via compactMap") func compactMapDocumentParts() {
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
}
