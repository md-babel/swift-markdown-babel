public struct Map<Upstream, To>
where Upstream: Transformer {
	public typealias From = Upstream.To
	public typealias Transformation = (From) -> To

	@usableFromInline
	let upstream: Upstream

	@usableFromInline
	let transform: Transformation

	@inlinable @inline(__always)
	public init(
		from upstream: Upstream,
		transform: @escaping Transformation
	) {
		self.upstream = upstream
		self.transform = transform
	}
}

extension Map: Transformer {}

extension Map {
	@inlinable @inline(__always)
	public func pipe(to sink: Sink<To>) {
		self.upstream.do { sink(self.transform($0)) }
	}
}
