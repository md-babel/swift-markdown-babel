public struct Map<From, To, T>
where T: Transformer, T.To == From {
	typealias Transformation = (From) -> To

	let from: T
	let transform: Transformation
}

extension Map: Transformer {}

extension Map {
	public func `do`(_ sink: @escaping (To) -> Void) {
		self.from.do { sink(self.transform($0)) }
	}
}
