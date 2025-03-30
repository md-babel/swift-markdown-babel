public struct Map<Upstream, Transformed>
where Upstream: Transformer {
	public typealias From = Upstream.To
	public typealias Transformation = (From) -> Transformed

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

extension Map: Transformer {
	@inlinable @inline(__always)
	public func pipe(to sink: NonThrowingSink<Transformed>) {
		self.upstream.pipe(to: NonThrowingSink { sink(self.transform($0)) })
	}

	@inlinable @inline(__always)
	public func pipe(to sink: ThrowingSink<Transformed>) throws {
		try self.upstream.pipe(to: ThrowingSink { try sink(self.transform($0)) })
	}
}
