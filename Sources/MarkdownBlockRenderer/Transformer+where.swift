extension Transformer {
	/// Crude filter-like replacement, transforming elements to `Optional.none` iff `predicate` evaluates to `false`.
	public func `where`(
		_ predicate: @escaping (To) -> Bool
	) -> Map<To, To?, Self> {
		return map { predicate($0) ? $0 : nil }
	}
}
