import struct Foundation.URL

public struct GenerateImageFileURL: Sendable {
	public let outputDirectory: URL
	public let fileExtension: String

	public init(outputDirectory: URL, fileExtension: String) {
		self.outputDirectory = outputDirectory
		self.fileExtension = fileExtension
	}

	public func url(filename: String) -> URL {
		return
			outputDirectory
			.appending(path: filename)
			.appendingPathExtension(fileExtension)
	}

	@inlinable @inline(__always)
	public func callAsFunction(filename: String) -> URL {
		return url(filename: filename)
	}
}
