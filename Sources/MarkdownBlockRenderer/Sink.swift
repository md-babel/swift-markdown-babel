/// Sink ends a transformation chain.
public struct Sink<Element> {
	@usableFromInline
	let sink: (Element) -> Void

	@inlinable @inline(__always)
	public init(_ sink: @escaping (Element) -> Void) {
		self.sink = sink
	}

	@usableFromInline
	func callAsFunction(_ element: Element) {
		self.sink(element)
	}
}
