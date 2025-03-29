public protocol Transformer<From, To> {
	associatedtype From
	associatedtype To

	/// End the transformation chain by executing it, piping results to `sink`.
	func pipe(to sink: Sink<To>)
}

extension Transformer {
	/// Sink that ends the transformation chain.
	@inlinable @inline(__always)
	public func `do`(_ sink: @escaping (To) -> Void) {
		self.pipe(to: Sink(sink))
	}
}
