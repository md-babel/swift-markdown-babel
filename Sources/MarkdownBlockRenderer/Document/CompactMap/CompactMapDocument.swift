import Markdown

public struct CompactMapDocument<Base, Transformed>: Document, DocumentScope
where Base: Document, Transformed: Markdown.Markup {
	public typealias Element = Transformed

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
