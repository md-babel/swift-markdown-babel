import Markdown
import MarkdownBabel
import Testing

extension Markdown.Markup {
	func dump() -> String {
		return debugDescription(options: .printSourceLocations)
	}
}

@Suite("Markup at location") struct MarkupAtLocation {
	@Suite("in an empty document") struct EmptyDocument {
		let document = MarkdownDocument(parsing: "")

		// swift-format-ignore: AlwaysUseLowerCamelCase
		@Test(
			"at invalid values before {1,1}, outside the domain, returns nil",
			arguments: [(0, 0), (0, -1), (-1, 1), (-1, 0), (-1, -1)]
		) func beforeValidDomainValues_IsNil(location: (line: Int, column: Int)) {
			let location = SourceLocation(line: location.line, column: location.column, source: nil)
			#expect(document.markup(at: location) == nil)
		}

		// swift-format-ignore: AlwaysUseLowerCamelCase
		@Test("at {1,1}, the beginning of document location, returns nil") func atOne_IsNil() {
			let location = SourceLocation(line: 1, column: 1, source: nil)
			#expect(document.markup(at: location) == nil)
		}

		// swift-format-ignore: AlwaysUseLowerCamelCase
		@Test(
			"at values beyond EOF, returns nil",
			arguments: [(1, 2), (2, 1), (100, 1)]
		) func afterEOF_IsNil(location: (line: Int, column: Int)) {
			let location = SourceLocation(line: location.line, column: location.column, source: nil)
			#expect(document.markup(at: location) == nil)
		}
	}

	@Suite("in paragraph with nested inline markup") struct ParagraphWithInline {
		let document = MarkdownDocument(
			parsing: """
				Hello, _markup `world`_!

				"""
		)

		// swift-format-ignore: AlwaysUseLowerCamelCase
		@Test(
			"at invalid values before {1,1}, outside the domain, returns nil",
			arguments: [(0, 0), (0, -1), (-1, 1), (-1, 0), (-1, -1)]
		) func beforeValidDomainValues_IsNil(location: (line: Int, column: Int)) {
			let location = SourceLocation(line: location.line, column: location.column, source: nil)
			#expect(document.markup(at: location) == nil)
		}

		@Test(
			"start of document returns text in paragraph block",
			arguments: [(1, 1), (1, 2), (1, 7)]
		)
		func atStart(location: (line: Int, column: Int)) {
			let location = SourceLocation(line: location.line, column: location.column, source: nil)
			let expectedDump =
				"""
				├─ Text @1:1-1:8 "Hello, "
				"""
			#expect(document.markup(at: location)?.dump() == expectedDump)
		}

		@Test(
			"at emphasis markers returns subtree",
			arguments: [(1, 8), (1, 23)]
		)
		func atEmphasisMarkers(location: (line: Int, column: Int)) {
			let location = SourceLocation(line: location.line, column: location.column, source: nil)
			let expectedDump =
				"""
				├─ Emphasis @1:8-1:24
				│  ├─ Text @1:9-1:16 "markup "
				│  └─ InlineCode @1:16-1:23 `world`
				"""
			#expect(document.markup(at: location)?.dump() == expectedDump)
		}

		@Test(
			"inside emphasis but outside inline code returns emphasized text",
			arguments: [(1, 9), (1, 10), (1, 15)]
		)
		func inEmphasis(location: (line: Int, column: Int)) {
			let location = SourceLocation(line: location.line, column: location.column, source: nil)
			let expectedDump =
				"""
				├─ Text @1:9-1:16 "markup "
				"""
			#expect(document.markup(at: location)?.dump() == expectedDump)
		}

		@Test(
			"at or inside inline code markers",
			arguments: [
				(1, 17), (1, 22),  // backticks
				(1, 18), (1, 19), (1, 20), (1, 21),  // code
			]
		)
		func inCode(location: (line: Int, column: Int)) {
			let location = SourceLocation(line: location.line, column: location.column, source: nil)
			let expectedDump =
				"""
				└─ InlineCode @1:16-1:23 `world`
				"""
			#expect(document.markup(at: location)?.dump() == expectedDump)
		}
	}

	@Test("deeply nested markup") func deeplyNested() {
		let document = MarkdownDocument(
			parsing: """
				-   List
				    -   Item

				        > Blockquote
				        >
				        > > Deep *nested in **quotes***.

				"""
		)

		let location = SourceLocation(line: 6, column: 33, source: nil)
		let expectedDump =
			"""
			└─ Text @6:31-6:37 "quotes"
			"""
		#expect(document.markup(at: location)?.dump() == expectedDump)
	}
}
