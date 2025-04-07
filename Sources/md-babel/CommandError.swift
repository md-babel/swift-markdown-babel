struct GenericError: Error, CustomStringConvertible {
	let message: String
	var description: String { "Error: \(message)" }
}
