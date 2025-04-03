import Markdown

public struct AnyFilterDocument<Base>: Document
where Base: Document {
	public let base: Base
	public let predicate: (AnyElement) -> Bool

	public init(
		base: Base,
		_ predicate: @escaping (AnyElement) -> Bool
	) {
		self.base = base
		self.predicate = predicate
	}

	public func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> Markdown.Document {
		base.markdown(visitor: { element in
			guard predicate(element) else { return element }
			return visitor(element)
		})
	}
}
