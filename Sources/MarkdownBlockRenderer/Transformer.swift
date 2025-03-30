public protocol Transformer<From, To> {
	associatedtype From
	associatedtype To

	// End the transformation chain by executing it, piping results to `sink`.
	func pipe(to sink: NonThrowingSink<To>)

	// End the transformation chain by executing it, piping results to `sink`.
	func pipe(to sink: ThrowingSink<To>) throws
}

extension Transformer {
	/// Sink that ends the transformation chain.
	@inlinable @inline(__always)
	public func `do`(_ sink: @escaping (To) -> Void) {
		self.pipe(to: NonThrowingSink(sink))
	}

	/// Throwing sink that ends the transformation chain.
	@inlinable @inline(__always)
	public func `do`(_ sink: @escaping (To) throws -> Void) throws {
		try self.pipe(to: ThrowingSink(sink))
	}
}
