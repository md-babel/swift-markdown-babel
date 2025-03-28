import Foundation

/// Use to print to STDOUT in an orderly fashion (isolated to `MainActor`) iff ``isEnabled``.
struct VerboseLogger {
	let isEnabled: Bool

	@MainActor
	func callAsFunction(_ string: @autoclosure () -> String) throws {
		try log(string())
	}

	@MainActor
	func log(_ string: @autoclosure () -> String) throws {
		try log(try string().data())
	}

	@MainActor
	func log(_ data: @autoclosure () throws -> Data) throws {
		guard isEnabled else { return }
		try FileHandle.standardOutput.write(data())
	}
}
