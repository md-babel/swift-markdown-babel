import Markdown

public struct CompactMapDocument<Base, Transformed>: Document
where Base: Document, Transformed: Markdown.Markup {
	public let base: Base
	public let transform: (AnyElement) -> Transformed?

	public init(
		base: Base,
		_ transform: @escaping (AnyElement) -> Transformed?
	) {
		self.base = base
		self.transform = transform
	}

	public func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> Base.VisitedDocument {
		return base.markdown(visitor: { transform($0).flatMap(visitor) ?? $0 })
	}

	public func markdown() -> Markdown.Document {
		return base.markdown(visitor: { transform($0) ?? $0 }).markdown()
	}
}

extension Document {
	@_disfavoredOverload
	@inlinable @inline(__always)
	public func compactMap<Transformed>(
		_ transform: @escaping (AnyElement) -> Transformed?
	) -> CompactMapDocument<Self, Transformed>
	where Transformed: Markdown.Markup {
		return CompactMapDocument(base: self, transform)
	}
}

extension CompactMapDocument {
	@inlinable @inline(__always)
	public func map(_ transform: @escaping (Transformed) -> AnyElement?) -> AnyMapDocument<Self> {
		return AnyMapDocument(base: self, { transform($0 as! Transformed) })
	}

	@inlinable @inline(__always)
	public func filter(_ predicate: @escaping (Transformed) -> Bool) -> FilterDocument<Self, Transformed> {
		return FilterDocument(base: self, { predicate($0) })
	}

	@inlinable @inline(__always)
	public func compactMap<OtherTransformed>(
		_ transform: @escaping (Transformed) -> OtherTransformed?
	) -> CompactMapDocument<Self, OtherTransformed>
	where OtherTransformed: Markdown.Markup {
		return CompactMapDocument<Self, OtherTransformed>(base: self, { transform($0 as! Transformed) })
	}
}
