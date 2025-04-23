import struct Foundation.URL

public struct GenerateImageFileURL: Equatable, Sendable {
	public let outputDirectory: URL
	public let fileExtension: String

	public init(outputDirectory: URL, fileExtension: String) {
		self.outputDirectory = outputDirectory
		self.fileExtension = fileExtension
	}

	public func url(filename: String, directory: String) -> URL {
		return
			URL(fileURLWithPath: directory, relativeTo: outputDirectory)
			.appending(path: filename)
			.appendingPathExtension(fileExtension)
	}

	@inlinable @inline(__always)
	public func callAsFunction(filename: String, directory: String) -> URL {
		return url(filename: filename, directory: directory)
	}
}
