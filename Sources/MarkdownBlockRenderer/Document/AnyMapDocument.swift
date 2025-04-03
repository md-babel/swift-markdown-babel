import Markdown

public struct AnyMapDocument<Base>: Document
where Base: Document {
	public let base: Base
	public let transform: (AnyElement) -> AnyElement?

	public init(
		base: Base,
		_ transform: @escaping (AnyElement) -> AnyElement?
	) {
		self.base = base
		self.transform = transform
	}

	public func markdown(visitor: @escaping (AnyElement) -> AnyElement?) -> Markdown.Document {
		base.markdown(visitor: { transform($0).flatMap(visitor) })
	}
}
