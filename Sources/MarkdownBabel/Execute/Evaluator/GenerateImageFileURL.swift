import struct Foundation.URL

public struct GenerateImageFileURL: Equatable, Sendable {
	public let outputDirectory: URL

	public init(outputDirectory: URL) {
		self.outputDirectory = outputDirectory
	}

	public func url(filename: String, fileExtension: String, directory: String?) -> URL {
		let baseDirectory =
			if let directory {
				URL(fileURLWithPath: directory, relativeTo: outputDirectory)
			} else {
				outputDirectory
			}
		return
			baseDirectory
			.appending(path: filename)
			.appendingPathExtension(fileExtension)
	}

	@inlinable @inline(__always)
	public func callAsFunction(filename: String, fileExtension: String, directory: String?) -> URL {
		return url(filename: filename, fileExtension: fileExtension, directory: directory)
	}
}

extension GenerateImageFileURL {
	@inlinable @inline(__always)
	public func url(filename: String, imageConfiguration: ImageEvaluationConfiguration) -> URL {
		return url(
			filename: filename,
			fileExtension: imageConfiguration.fileExtension,
			directory: imageConfiguration.directory
		)
	}

	@inlinable @inline(__always)
	public func callAsFunction(filename: String, imageConfiguration: ImageEvaluationConfiguration) -> URL {
		return url(filename: filename, imageConfiguration: imageConfiguration)
	}
}
