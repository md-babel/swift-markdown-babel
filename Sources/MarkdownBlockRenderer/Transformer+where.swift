extension Transformer {
	/// Crude filter-like replacement, transforming elements to `Optional.none` iff `predicate` evaluates to `false`.
	@inlinable @inline(__always)
	public func `where`(
		_ predicate: @escaping (To) -> Bool
	) -> Map<Self, To?> {
		return map { predicate($0) ? $0 : nil }
	}
}
