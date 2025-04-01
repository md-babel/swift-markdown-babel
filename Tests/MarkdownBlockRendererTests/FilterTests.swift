import Markdown
import MarkdownBlockRenderer
import Testing

@Suite("Filtering") struct FilterTests {
	@Suite("just one value") struct JustOneValue {
		let isOdd = { (num: Int) -> Bool in
			num % 2 == 1
		}

		@Test func predicateReturnsTrue() {
			let results = collect {
				Filter(from: Just(3), predicate: isOdd)
			}
			#expect(results == [3])
		}

		@Test func predicateReturnsFalse() {
			let results = collect {
				Filter(from: Just(2), predicate: isOdd)
			}
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
			let results = collect {
				document
					.filter { $0 is Markdown.Text && !($0.parent is Markdown.Heading) }
					.map { $0.format() }
			}
			#expect(
				results == [
					"Text in chapter",
					"Text in section",
				]
			)
		}
	}
}
