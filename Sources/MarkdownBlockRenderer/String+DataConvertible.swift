import struct Foundation.Data

extension String: DataConvertible {
	public func data() throws(DataConversionFailed) -> Data {
		guard let result = data(using: .utf8)
		else { throw DataConversionFailed(message: "Converting to UTF-8 data: \(self)") }
		return result
	}
}
