extension Transformer {
	/// Transform the output element of `self` to an optional downstream element, skipping `nil`.
	@inlinable @inline(__always)
	public func compactMap<Next>(
		_ transform: @escaping (To) -> Next?
	) -> CompactMap<Self, Next> {
		return CompactMap(from: self, transform: transform)
	}
}
