extension Transformer {
	public func map<Next>(
		_ transform: @escaping (To) -> Next
	) -> Map<To, Next, Self> {
		return Map(from: self, transform: transform)
	}
}
