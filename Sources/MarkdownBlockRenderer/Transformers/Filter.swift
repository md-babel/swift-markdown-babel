public struct Filter<Upstream>
where Upstream: Transformer {
	public typealias From = Upstream.To
	public typealias To = From
	public typealias Predicate = (_ element: From) -> Bool

	@usableFromInline
	let upstream: Upstream

	@usableFromInline
	let predicate: Predicate

	@inlinable @inline(__always)
	public init(
		from upstream: Upstream,
		predicate: @escaping Predicate
	) {
		self.upstream = upstream
		self.predicate = predicate
	}
}

extension Filter: Transformer {
	@inlinable @inline(__always)
	public func pipe(to sink: NonThrowingSink<To>) {
		self.upstream.pipe(
			to: NonThrowingSink {
				guard self.predicate($0) else { return }
				sink($0)
			}
		)
	}

	@inlinable @inline(__always)
	public func pipe(to sink: ThrowingSink<To>) throws {
		try self.upstream.pipe(
			to: ThrowingSink {
				guard self.predicate($0) else { return }
				try sink($0)
			}
		)
	}
}
