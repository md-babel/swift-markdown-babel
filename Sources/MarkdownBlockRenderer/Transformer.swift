public protocol Transformer<From, To> {
	associatedtype From
	associatedtype To

	func `do`(_ sink: @escaping (To) -> Void)
}
