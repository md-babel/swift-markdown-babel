import Markdown
import MarkdownBlockRenderer
import Testing

@Suite("Compact Mapping") struct CompactMapsTests {
	@Suite("just one value") struct JustOneValue {
		let even = { (num: Int) -> Int? in
			num % 2 == 0 ? num : nil
		}

		@Test func transformationReturnsNil() {
			let results = collect {
				CompactMap(from: Just(3), transform: even)
			}
			#expect(results == [])
		}

		@Test func transformationReturnsValue() {
			let results: [Int] = collect {
				CompactMap(from: Just(2), transform: even)
			}
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
			let results = collect {
				document
					.forEach(Markdown.Heading.self)
					.map { heading in
						"\(heading.level): \((heading.child(at: 0) as! Markdown.Text).string)"
					}
			}
			#expect(
				results == [
					"1: Chapter",
					"2: Section",
					"3: Subsection",
				]
			)
		}

		@Test("via compactMap") func compactMapDocumentParts() {
			let results = collect {
				document
					.compactMap { $0 as? Markdown.Heading }
					.map { heading in
						"\(heading.level): \((heading.child(at: 0) as! Markdown.Text).string)"
					}
			}
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
