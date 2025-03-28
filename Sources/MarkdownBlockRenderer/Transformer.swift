public protocol Transformer {
	associatedtype Output

	/// Terminating transformation.
	func `do`(_ sink: @escaping (Output) -> Void)
}
