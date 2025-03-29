public protocol Transformer<From, To> {
	associatedtype From
	associatedtype To

	/// Sink that ends the transformation chain.
	func `do`(_ sink: @escaping (To) -> Void)
}
