public struct CompactMap<Upstream, Transformed>
where Upstream: Transformer {
	public typealias From = Upstream.To
	public typealias Transformation = (From) -> Transformed?

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

extension CompactMap: Transformer {
	@inlinable @inline(__always)
	public func pipe(to sink: NonThrowingSink<Transformed>) {
		self.upstream.pipe(
			to: NonThrowingSink {
				guard let element = self.transform($0) else { return }
				sink(element)
			}
		)
	}

	@inlinable @inline(__always)
	public func pipe(to sink: ThrowingSink<Transformed>) throws {
		try self.upstream.pipe(
			to: ThrowingSink {
				guard let element = self.transform($0) else { return }
				try sink(element)
			}
		)
	}
}
