import Testing

@testable import md_babel

@Suite struct PositiveNonZeroParsing {
	@Test(
		"Text only throws parsing error",
		arguments: [
			"",
			"text",
			"mixed 123",
			"123 mixed",
		]
	) func textOnly(string: String) {
		#expect(throws: SourceLocationParsingError.notANumber(string)) {
			try positiveNonZero(string)
		}
	}

	@Test(
		"Decimals number throws parsing error",
		arguments: [
			".4",
			"4.4",
			"-1.0",
			"0.0",
		]
	) func decimalNumber(string: String) {
		#expect(throws: SourceLocationParsingError.notANumber(string)) {
			try positiveNonZero(string)
		}
	}

	@Test(
		"Integer out of range throws parsing error",
		arguments: [
			("-123", -123),
			("-1", -1),
			("-0", 0),
			("0", 0),
			("00", 0),
		]
	) func integerOutOfRange(string: String, expectedInt: Int) {
		#expect(throws: SourceLocationParsingError.notAPositiveNonZeroNumber(string, expectedInt)) {
			try positiveNonZero(string)
		}
	}

	@Test(
		"Integer out of range throws parsing error",
		arguments: [
			("\(Int.max)", Int.max),
			("123", 123),
			("1", 1),
			("01", 1),
		]
	) func validInteger(string: String, expectedInt: Int) throws {
		#expect(try positiveNonZero(string) == expectedInt)
	}
}
