extension Transformer {
	/// Transform the output element of `self` to an optional downstream element, skipping `nil`.
	@inlinable @inline(__always)
	public func compactMap<Next>(
		_ transform: @escaping (To) -> Next?
	) -> CompactMap<Self, Next> {
		return CompactMap(from: self, transform: transform)
	}
}

extension Transformer {
	/// Filter output element of `self` with `predicate`, skipping elements that don't satisfy the test.
	///
	/// - See: ``compactMap(_:)`` and ``CompactMap`` as the underlying transformation.
	@inlinable @inline(__always)
	public func `where`(
		_ predicate: @escaping (To) -> Bool
	) -> CompactMap<Self, To> {
		return compactMap { predicate($0) ? $0 : nil }
	}
}
