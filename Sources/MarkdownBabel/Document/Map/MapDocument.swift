import Markdown

public struct MapDocument<Base, Transformed>: Document, DocumentScope
where Base: Document, Transformed: Markdown.Markup {
	public typealias Element = Transformed

	public let base: Base
	public let transform: (AnyElement) -> Transformed

	public init(
		base: Base,
		_ transform: @escaping (AnyElement) -> Transformed
	) {
		self.base = base
		self.transform = transform
	}

	public func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> Base.VisitedDocument {
		return base.markdown(visitor: { visitor(transform($0)) })
	}

	public func markdown() -> Markdown.Document {
		return base.markdown(visitor: transform).markdown()
	}
}
