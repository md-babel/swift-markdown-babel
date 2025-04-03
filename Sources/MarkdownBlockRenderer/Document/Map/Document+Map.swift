import Markdown

extension Document {
	@inlinable @inline(__always)
	public func map<Transformed>(
		_ transform: @escaping (AnyElement) -> Transformed
	) -> MapDocument<Self, Transformed>
	where Transformed: Markdown.Markup {
		return MapDocument<Self, Transformed>(base: self, transform)
	}
}
