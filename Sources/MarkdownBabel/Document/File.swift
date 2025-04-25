import struct Foundation.URL

/// The input file used during parsing.
public struct File: Equatable, Sendable, CustomStringConvertible {
	public static let standardInput = File(filename: "STDIN")

	public let filename: String
	public let sourceURL: URL?

	public var description: String {
		[sourceURL?.path(), filename].compactMap { $0 }.joined(separator: ": ")
	}

	public init(filename: String) {
		self.filename = filename
		self.sourceURL = nil
	}

	public init(sourceURL: URL) {
		self.filename = sourceURL.deletingPathExtension().lastPathComponent
		self.sourceURL = sourceURL
	}
}
