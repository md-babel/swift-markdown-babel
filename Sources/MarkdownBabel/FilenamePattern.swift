import Foundation

/// - Parameters:
///   - pattern: [Unicode TR-35](https://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns) pattern. Enquote literal string parts with single quotes; everything else may be interpreted as a date format pattern.
///   - sourceFilename: Will be inserted in place of occurrences of "`$fn`" in `pattern`.
///   - contentHash: Will be inserted in place of occurrences of "`$hash`" in `pattern`.
///   - locale: Locale used for date formatting. Defaults to `en_US_POSIX`.
///   - timeZone: Time zone used for date formatting. Defaults to the device's current.
///   - now: Returns the date that represents the current date and time at the moment of the function call. (Testing seam.)
/// - Returns: Formatted string.
public func filename(
	pattern: String,
	sourceFilename: String,
	contentHash: String,
	locale: Locale = Locale(identifier: "en_US_POSIX"),
	timeZone: TimeZone = .autoupdatingCurrent,
	now: () -> Date = { Date.now }
) -> String {
	let formatter = DateFormatter()
	formatter.timeZone = timeZone
	formatter.locale = locale
	formatter.dateFormat = pattern
	return
		formatter
		.string(from: now())
		.replacing("$fn", with: sourceFilename)
		.replacing("$hash", with: contentHash)
}
