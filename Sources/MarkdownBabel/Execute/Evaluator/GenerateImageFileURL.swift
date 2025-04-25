import struct Foundation.URL

public struct GenerateImageFileURL: Equatable, Sendable {
	public let outputDirectory: URL
	public let produceRelativePaths: Bool

	public init(
		outputDirectory: URL,
		produceRelativePaths: Bool
	) {
		self.outputDirectory = outputDirectory
		self.produceRelativePaths = produceRelativePaths
	}

	public func url(
		filename: String,
		fileExtension: String,
		directory: String?
	) -> ImageFileURL {
		let baseDirectory =
			if let directory {
				URL(fileURLWithPath: directory, relativeTo: outputDirectory)
			} else {
				outputDirectory
			}
		let fileURL =
			baseDirectory
			.appending(path: filename)
			.appendingPathExtension(fileExtension)
		return ImageFileURL(
			fileURL: fileURL,
			relativizigWorkingDirectory: produceRelativePaths ? outputDirectory : nil
		)
	}

	@inlinable @inline(__always)
	public func callAsFunction(
		filename: String,
		fileExtension: String,
		directory: String?
	) -> ImageFileURL {
		return url(
			filename: filename,
			fileExtension: fileExtension,
			directory: directory
		)
	}
}

extension GenerateImageFileURL {
	@inlinable @inline(__always)
	public func url(
		filename: String,
		imageConfiguration: ImageEvaluationConfiguration
	) -> ImageFileURL {
		return url(
			filename: filename,
			fileExtension: imageConfiguration.fileExtension,
			directory: imageConfiguration.directory
		)
	}

	@inlinable @inline(__always)
	public func callAsFunction(
		filename: String,
		imageConfiguration: ImageEvaluationConfiguration
	) -> ImageFileURL {
		return url(
			filename: filename,
			imageConfiguration: imageConfiguration
		)
	}
}
