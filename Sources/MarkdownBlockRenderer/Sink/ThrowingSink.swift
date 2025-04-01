/// Sink ends a transformation chain.
public struct ThrowingSink<Element>: Sink {
	@usableFromInline
	let sink: (Element) throws -> Void

	@inlinable @inline(__always)
	public init(_ sink: @escaping (Element) throws -> Void) {
		self.sink = sink
	}

	@inlinable @inline(__always)
	public func callAsFunction(_ element: Element) throws {
		try self.sink(element)
	}
}
