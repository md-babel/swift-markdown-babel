extension Transformer {
	@inlinable @inline(__always)
	public func map<Next>(
		_ transform: @escaping (To) -> Next
	) -> Map<Self, Next> {
		return Map(from: self, transform: transform)
	}
}
