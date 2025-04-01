import Markdown
import MarkdownBlockRenderer
import Testing

@Suite struct MapsTests {
	@Test func mapJustOneValue() {
		let results = collect {
			Map(from: Just(123)) { "\($0 * 2)" }
		}
		#expect(results == ["246"])
	}

	@Test func mapDocumentParts() {
		let document = MarkdownDocument(
			parsing:
				"""
				# 1
				## 11
				### 111
				## 12
				# 2
				## 22
				# 3
				"""
		)
		let results = collect {
			document
				.map { markup in
					guard let heading = markup as? Markdown.Heading else {
						return (0, markup)
					}
					let headingTextValue = Int((heading.child(at: 0) as! Markdown.Text).string)!
					let value = heading.level * headingTextValue
					return (value, markup)
				}
				.map { (value, markup) in
					"\(value): \(type(of: markup))"
				}
		}
		#expect(
			results == [
				"0: Document",
				"1: Heading",
				"0: Text",
				"22: Heading",
				"0: Text",
				"333: Heading",
				"0: Text",
				"24: Heading",
				"0: Text",
				"2: Heading",
				"0: Text",
				"44: Heading",
				"0: Text",
				"3: Heading",
				"0: Text",
			]
		)
	}
}
