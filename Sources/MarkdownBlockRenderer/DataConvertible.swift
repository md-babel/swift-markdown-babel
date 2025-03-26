import struct Foundation.Data

public struct DataConversionFailed: Error {
	public let message: String
}

public protocol DataConvertible: Sendable {
	func data() throws(DataConversionFailed) -> Data
}
