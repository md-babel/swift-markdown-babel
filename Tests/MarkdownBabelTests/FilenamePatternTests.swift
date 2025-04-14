import Foundation
import MarkdownBabel
import Testing

private let irrelevantFilename = "irrelevant"
private let irrelevantContentHash = "16n0r3d"
private let nowStub: @Sendable () -> Date = { Date(timeIntervalSince1970: 1_757_230_512) }

private func fn(
	pattern: String,
	sourceFilename: String = irrelevantFilename,
	contentHash: String = irrelevantContentHash,
	localeIdentifier: String = "en_US_POSIX"
) -> String {
	return filename(
		pattern: pattern,
		sourceFilename: sourceFilename,
		contentHash: contentHash,
		locale: Locale(identifier: localeIdentifier),
		now: nowStub
	)
}

@Suite struct FilenamePatternTests {
	@Test(arguments: [
		("", ""),
		("''", "'"),
		("''''", "''"),
		("'o''clock'", "o'clock"),
		("'fn'", "fn"),
		("'hash'", "hash"),
		("'test file'", "test file"),
		("'yyyy'", "yyyy"),
	]) func staticStringReturnsItself(pattern: String, expectedFilename: String) {
		#expect(fn(pattern: pattern) == expectedFilename)
	}

	@Test func filenameOutsideOfQuotes() {
		#expect(fn(pattern: "$fn") == "$")
	}

	@Test(arguments: [
		("'$fn'", "a 'replacement' filename"),
		("'\\$fn'", "\\a 'replacement' filename"),  // There is no escape
		("'prefix $fn'", "prefix a 'replacement' filename"),
		("'$fn suffix'", "a 'replacement' filename suffix"),
		("'in $fn fix'", "in a 'replacement' filename fix"),
	]) func filenameOnly(pattern: String, expectedFilename: String) {
		#expect(fn(pattern: pattern, sourceFilename: "a 'replacement' filename") == expectedFilename)
	}

	@Test(arguments: [
		("'$hash'", "d34db33f"),
		("'\\$hash'", "\\d34db33f"),  // There is no escape
		("'prefix $hash'", "prefix d34db33f"),
		("'$hash suffix'", "d34db33f suffix"),
		("'in $hash fix'", "in d34db33f fix"),
	]) func hashOnly(pattern: String, expectedFilename: String) {
		#expect(fn(pattern: pattern, contentHash: "d34db33f") == expectedFilename)
	}

	@Test(arguments: [
		("en_US_POSIX", "September"),
		("en_US", "September"),
		("fr_FR", "septembre"),
		("de_DE", "September"),
		("ko_KR", "9월"),
	]) func localizedDate(localeIdentifier: String, expectedFilename: String) {
		#expect(fn(pattern: "LLLL", localeIdentifier: localeIdentifier) == expectedFilename)
	}

	@Test(arguments: [
		("yyyyMMdd'T'HHmmss'--$fn__$hash'", "20250907T093512--Weird yyyy Filename__d34db33f"),
		("yyyyMMdd '$fn'", "20250907 Weird yyyy Filename"),
		("'rendered-$hash'", "rendered-d34db33f"),
	]) func mixedRealWorldPatterns(pattern: String, expectedFilename: String) {
		#expect(
			fn(pattern: pattern, sourceFilename: "Weird yyyy Filename", contentHash: "d34db33f")
				== expectedFilename
		)
	}
}
