public struct Map<Upstream, To>
where Upstream: Transformer {
	public typealias From = Upstream.To
	public typealias Transformation = (From) -> To

	@usableFromInline
	let upstream: Upstream

	@usableFromInline
	let transform: Transformation

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
	public func `do`(_ sink: @escaping (To) -> Void) {
		self.upstream.do { sink(self.transform($0)) }
	}
}
