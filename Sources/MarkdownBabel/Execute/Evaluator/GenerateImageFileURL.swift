import struct Foundation.URL

public struct GenerateImageFileURL: Equatable, Sendable {
	public let outputDirectory: URL

	public init(outputDirectory: URL) {
		self.outputDirectory = outputDirectory
	}

	public func url(
		filename: String,
		fileExtension: String,
		directory: String?,
		relativizePath: Bool
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
			relativizigWorkingDirectory: relativizePath ? outputDirectory : nil
		)
	}

	@inlinable @inline(__always)
	public func callAsFunction(
		filename: String,
		fileExtension: String,
		directory: String?,
		relativizePath: Bool
	) -> ImageFileURL {
		return url(
			filename: filename,
			fileExtension: fileExtension,
			directory: directory,
			relativizePath: relativizePath
		)
	}
}

extension GenerateImageFileURL {
	@inlinable @inline(__always)
	public func url(
		filename: String,
		imageConfiguration: ImageEvaluationConfiguration,
		relativizePath: Bool
	) -> ImageFileURL {
		return url(
			filename: filename,
			fileExtension: imageConfiguration.fileExtension,
			directory: imageConfiguration.directory,
			relativizePath: relativizePath
		)
	}

	@inlinable @inline(__always)
	public func callAsFunction(
		filename: String,
		imageConfiguration: ImageEvaluationConfiguration,
		relativizePath: Bool
	) -> ImageFileURL {
		return url(
			filename: filename,
			imageConfiguration: imageConfiguration,
			relativizePath: relativizePath
		)
	}
}
