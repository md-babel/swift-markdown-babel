import Foundation
import Markdown
import MarkdownBabel
import Testing

extension ExecutableContext {
	func dump() -> String {
		return debugDescription(options: .printSourceLocations)
	}
}

func range(
	from lineFrom: Int,
	_ columnFrom: Int,
	_ sourceFrom: URL? = nil,
	to lineTo: Int,
	_ columnTo: Int,
	_ sourceTo: URL? = nil
) -> SourceRange {
	let fromLocation = SourceLocation(
		line: lineFrom,
		column: columnFrom,
		source: sourceFrom
	)
	let toLocation = SourceLocation(
		line: lineTo,
		column: columnTo,
		source: sourceTo
	)
	return fromLocation..<toLocation
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

		@Test func returnsCodeBlockOnly() throws {
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
			let result = try #require(document.executableContext(at: location))
			#expect(result.encompassingRange == range(from: 3, 1, to: 6, 4))
			#expect(result.dump() == expectedDump)
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

		@Test func returnsCodeBlockOnly() throws {
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
			let result = try #require(document.executableContext(at: location))
			#expect(result.encompassingRange == range(from: 3, 1, to: 5, 4))
			#expect(result.dump() == expectedDump)
		}
	}

	@Suite("in code block with result first") struct CodeBlockWithResultFirst {
		static let resultBlock = """
			<!--Result:-->
			```
			Mon Apr  7 08:40:38 CEST 2025
			```
			"""

		@Test func returnsCodeBlockWithResult() throws {
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
			let result = try #require(document.executableContext(at: location))
			#expect(result.encompassingRange == range(from: 3, 1, to: 10, 4))
			#expect(result.dump() == expectedDump)
		}

		@Suite("followed by unsupported block") struct ThenUnsupportedBlock {
			@Test func returnsCodeBlockWithResult() throws {
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
				let result = try #require(document.executableContext(at: location))
				#expect(result.encompassingRange == range(from: 3, 1, to: 10, 4))
				#expect(result.dump() == expectedDump)
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

			@Test func returnsCodeBlockWithResult() throws {
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
				let result = try #require(document.executableContext(at: location))
				#expect(result.encompassingRange == range(from: 3, 1, to: 10, 4))
				#expect(result.dump() == expectedDump)
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

			@Test func returnsCodeBlockWithResultAndError() throws {
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
				let result = try #require(document.executableContext(at: location))
				#expect(result.encompassingRange == range(from: 3, 1, to: 15, 4))
				#expect(result.dump() == expectedDump)
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
		) func returnsCodeBlockWithErrorOnly(secondBlock: String) throws {
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
			let result = try #require(document.executableContext(at: location))
			#expect(result.encompassingRange == range(from: 3, 1, to: 10, 4))
			#expect(result.dump() == expectedDump)
		}
	}
}
