@rethrows public protocol Sink<Element> {
	associatedtype Element
	func callAsFunction(_ element: Element) throws
}
