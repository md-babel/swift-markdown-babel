public struct ImageEvaluationConfiguration: Equatable, Hashable, Sendable {
	public let fileExtension: String
	public let directory: String?
	public let filenamePattern: String

	public init(
		fileExtension: String,
		directory: String?,
		filenamePattern: String
	) {
		self.fileExtension = fileExtension
		self.directory = directory
		self.filenamePattern = filenamePattern
	}
}

extension ImageEvaluationConfiguration: CustomStringConvertible {
	public var description: String {
		return [
			directory,
			"\(filenamePattern).\(fileExtension)",
		]
		.compactMap { $0 }
		.joined(separator: "/")
	}
}
