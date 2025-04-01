extension Transformer {
	/// Filter output element of `self` with `predicate`, skipping elements that don't satisfy the test.
	///
	/// Syntactic sugar for ``filter(_:)``.
	@inlinable @inline(__always)
	public func `where`(
		_ predicate: @escaping (To) -> Bool
	) -> CompactMap<Self, To> {
		return filter(predicate)
	}

	/// Filter output element of `self` with `predicate`, skipping elements that don't satisfy the test.
	///
	/// - See: ``compactMap(_:)`` and ``CompactMap`` as the underlying transformation.
	@inlinable @inline(__always)
	public func filter(
		_ predicate: @escaping (To) -> Bool
	) -> CompactMap<Self, To> {
		return compactMap { predicate($0) ? $0 : nil }
	}
}
