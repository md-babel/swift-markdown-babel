/// Sink ends a transformation chain.
public struct NonThrowingSink<Element>: Sink {
	@usableFromInline
	let sink: (Element) -> Void

	@inlinable @inline(__always)
	public init(_ sink: @escaping (Element) -> Void) {
		self.sink = sink
	}

	@inlinable @inline(__always)
	public func callAsFunction(_ element: Element) {
		self.sink(element)
	}
}
