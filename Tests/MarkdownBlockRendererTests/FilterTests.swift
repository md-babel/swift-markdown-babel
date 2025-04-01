import Markdown
import MarkdownBlockRenderer
import Testing

@Suite("Filter") struct FilterTests {
	@Suite("just one value") struct JustOneValue {
		let isOdd = { (num: Int) -> Bool in
			num % 2 == 1
		}

		@Test func predicateReturnsTrue() {
			let compactMap = Filter(from: Just(3), predicate: isOdd)
			var results: [Int] = []
			compactMap.do { results.append($0) }
			#expect(results == [3])
		}

		@Test func predicateReturnsFalse() {
			let compactMap = Filter(from: Just(2), predicate: isOdd)
			var results: [Int] = []
			compactMap.do { results.append($0) }
			#expect(results == [])
		}
	}

	@Suite("on document") struct OnDocument {
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
		@Test func ignoresUnmatchedParts() {
			let filtered =
				document
				.filter { $0 is Markdown.Text && !($0.parent is Markdown.Heading) }
				.map { $0.format() }
			var results: [String] = []
			filtered.do { results.append($0) }
			#expect(
				results == [
					"Text in chapter",
					"Text in section",
				]
			)
		}
	}
}
