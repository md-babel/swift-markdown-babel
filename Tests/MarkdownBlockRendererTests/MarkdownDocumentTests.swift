import Markdown
import MarkdownBlockRenderer
import Testing

extension Markdown.Markup {
	func dump() -> String {
		return debugDescription(options: .printSourceLocations)
	}
}

extension ExecutableContext {
	func dump() -> String {
		return debugDescription(options: .printSourceLocations)
	}
}

@Suite("Markup at location") struct MarkupAtLocation {
	@Suite("in an empty document") struct EmptyDocument {
		let document = MarkdownDocument(parsing: "")

		@Test(
			"at invalid values before {1,1}, outside the domain, returns nil",
			arguments: [(0, 0), (0, -1), (-1, 1), (-1, 0), (-1, -1)]
		) func beforeValidDomainValues_IsNil(location: (line: Int, column: Int)) {
			let location = SourceLocation(line: location.line, column: location.column, source: nil)
			#expect(document.markup(at: location) == nil)
		}

		@Test("at {1,1}, the beginning of document location, returns nil") func atOne_IsNil() {
			let location = SourceLocation(line: 1, column: 1, source: nil)
			#expect(document.markup(at: location) == nil)
		}

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

@Suite("ExecutableContext at location") struct ExecutableContextAtLocation {
	private static func makeDocument(
		followCodeWithBlock firstBlock: String = "",
		andThen secondBlock: String = ""
	) -> MarkdownDocument {
		return MarkdownDocument(
			parsing: """
				before

				```sh
				date
				```

				\(firstBlock)

				\(secondBlock)

				after
				"""
		)
	}

	@Suite("in code block without context") struct CodeBlockOnly {
		let document = MarkdownDocument(
			parsing: """
				before

				```agda
				η-× : ∀ {A B : Set} (w : A × B) → ⟨ proj₁ w , proj₂ w ⟩ ≡ w
				η-× w = refl
				```

				after
				"""
		)

		@Test func returnsCodeBlockOnly() {
			let location = SourceLocation(line: 4, column: 1, source: nil)
			let expectedDump = """
				Code:
				├─ CodeBlock @3:1-6:4 language: agda
				│  η-× : ∀ {A B : Set} (w : A × B) → ⟨ proj₁ w , proj₂ w ⟩ ≡ w
				│  η-× w = refl
				Result:
				(No Result)
				Error:
				(No Error)
				"""
			#expect(document.executableContext(at: location)?.dump() == expectedDump)
		}
	}

	@Suite("in code block followed by comment with unexpected header") struct CodeBlockWithUnsupportedComment {
		let document = makeDocument(
			followCodeWithBlock: """
				<!--Unsupported:-->
				```
				Should not match
				```
				"""
		)

		@Test func returnsCodeBlockOnly() {
			let location = SourceLocation(line: 4, column: 1, source: nil)
			let expectedDump = """
				Code:
				├─ CodeBlock @3:1-5:4 language: sh
				│  date
				Result:
				(No Result)
				Error:
				(No Error)
				"""
			#expect(document.executableContext(at: location)?.dump() == expectedDump)
		}
	}

	@Suite("in code block with result first") struct CodeBlockWithResultFirst {
		static let resultBlock = """
			<!--Result:-->
			```
			Mon Apr  7 08:40:38 CEST 2025
			```
			"""

		@Test func returnsCodeBlockWithResult() {
			let document = makeDocument(followCodeWithBlock: Self.resultBlock)
			let location = SourceLocation(line: 4, column: 1, source: nil)
			let expectedDump = """
				Code:
				├─ CodeBlock @3:1-5:4 language: sh
				│  date
				Result:
				» Range: 7:1..<10:4
				» Header: “Result:”
				» Content:
				  Mon Apr  7 08:40:38 CEST 2025
				» Content markup:
				  ├─ CodeBlock @8:1-10:4 language: none
				  │  Mon Apr  7 08:40:38 CEST 2025
				Error:
				(No Error)
				"""
			#expect(document.executableContext(at: location)?.dump() == expectedDump)
		}

		@Suite("followed by unsupported block") struct ThenUnsupportedBlock {
			@Test func returnsCodeBlockWithResult() {
				let document = makeDocument(
					followCodeWithBlock: CodeBlockWithResultFirst.resultBlock,
					andThen: """
						<!--Unsupported:-->
						```
						Should not match
						```
						"""
				)
				let location = SourceLocation(line: 4, column: 1, source: nil)
				let expectedDump = """
					Code:
					├─ CodeBlock @3:1-5:4 language: sh
					│  date
					Result:
					» Range: 7:1..<10:4
					» Header: “Result:”
					» Content:
					  Mon Apr  7 08:40:38 CEST 2025
					» Content markup:
					  ├─ CodeBlock @8:1-10:4 language: none
					  │  Mon Apr  7 08:40:38 CEST 2025
					Error:
					(No Error)
					"""
				#expect(document.executableContext(at: location)?.dump() == expectedDump)
			}
		}

		@Suite("followed by another result") struct ThenAnotherResult {
			let document = makeDocument(
				followCodeWithBlock: """
					<!--Result:-->
					```
					First of two results shadows the next
					```
					""",
				andThen: """
					<!--Result:-->
					```
					Second result is ignored
					```
					"""
			)

			@Test func returnsCodeBlockWithResult() {
				let location = SourceLocation(line: 4, column: 1, source: nil)
				let expectedDump = """
					Code:
					├─ CodeBlock @3:1-5:4 language: sh
					│  date
					Result:
					» Range: 7:1..<10:4
					» Header: “Result:”
					» Content:
					  First of two results shadows the next
					» Content markup:
					  ├─ CodeBlock @8:1-10:4 language: none
					  │  First of two results shadows the next
					Error:
					(No Error)
					"""
				#expect(document.executableContext(at: location)?.dump() == expectedDump)
			}
		}

		@Suite("followed by error") struct ThenError {
			let document = makeDocument(
				followCodeWithBlock: """
					<!--Result:-->
					```
					Mon Apr  7 10:51:55 CEST 2025
					```
					""",
				andThen: """
					<!--Error:-->
					```
					You are too slow!
					```
					"""
			)

			@Test func returnsCodeBlockWithResultAndError() {
				let location = SourceLocation(line: 4, column: 1, source: nil)
				let expectedDump = """
					Code:
					├─ CodeBlock @3:1-5:4 language: sh
					│  date
					Result:
					» Range: 7:1..<10:4
					» Header: “Result:”
					» Content:
					  Mon Apr  7 10:51:55 CEST 2025
					» Content markup:
					  ├─ CodeBlock @8:1-10:4 language: none
					  │  Mon Apr  7 10:51:55 CEST 2025
					Error:
					» Range: 12:1..<15:4
					» Header: “Error:”
					» Content:
					  You are too slow!
					» Content markup:
					  ├─ CodeBlock @13:1-15:4 language: none
					  │  You are too slow!
					"""
				#expect(document.executableContext(at: location)?.dump() == expectedDump)
			}
		}
	}

	@Suite("in code block with error first, no matter what comes after,") struct CodeBlockWithErrorFirst {
		@Test(
			"returns error only (ignoring the rest)",
			arguments: [
				// Empty block (error block only)
				"",

				// Result block, but after error
				"""
				<!--Result:-->
				```
				Mon Apr  7 10:51:55 CEST 2025
				```
				""",

				// Unrecognized block
				"""
				<!--Unsupported:-->
				```
				Should not match
				```
				""",

				// Multiple error blocks
				"""
				<!--Error:-->
				```
				Second error
				```
				""",
			]
		) func returnsCodeBlockWithErrorOnly(secondBlock: String) {
			let document = makeDocument(
				followCodeWithBlock: """
					<!--Error:-->
					```
					You are too slow!
					```
					""",
				andThen: secondBlock
			)

			let location = SourceLocation(line: 4, column: 1, source: nil)
			let expectedDump = """
				Code:
				├─ CodeBlock @3:1-5:4 language: sh
				│  date
				Result:
				(No Result)
				Error:
				» Range: 7:1..<10:4
				» Header: “Error:”
				» Content:
				  You are too slow!
				» Content markup:
				  ├─ CodeBlock @8:1-10:4 language: none
				  │  You are too slow!
				"""
			#expect(document.executableContext(at: location)?.dump() == expectedDump)
		}
	}
}
