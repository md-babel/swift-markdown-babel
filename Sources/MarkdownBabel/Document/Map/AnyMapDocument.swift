import Markdown

public struct AnyMapDocument<Base>: Document
where Base: Document {
	public let base: Base
	public let transform: (AnyElement) -> AnyElement

	public init(
		base: Base,
		_ transform: @escaping (AnyElement) -> AnyElement
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
