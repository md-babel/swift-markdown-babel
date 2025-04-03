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

	public func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> Base.VisitedDocument {
		return base.markdown(visitor: { element in
			guard predicate(element) else { return element }
			return visitor(element)
		})
	}
}

extension Document {
	@inlinable @inline(__always)
	public func filter(_ predicate: @escaping (AnyElement) -> Bool) -> some Document {
		return AnyFilterDocument(base: self, predicate)
	}
}
