import struct Foundation.URL

public struct ImageFileURL: Equatable, Sendable {
	/// Absolute file URL of the image.
	public let fileURL: URL

	/// Base directory used to resolve ``path()`` as relative. `nil` denotes absolute paths.
	public let relativizigWorkingDirectory: URL?

	public init(
		fileURL: URL,
		relativizigWorkingDirectory: URL? = nil
	) {
		self.fileURL = fileURL
		self.relativizigWorkingDirectory = relativizigWorkingDirectory
	}

	public func path() -> String {
		guard let relativizigWorkingDirectory else {
			return fileURL.absoluteURL.path()
		}

		return fileURL.absoluteURL.relativePath(resolvedAgainst: relativizigWorkingDirectory)
	}
}
