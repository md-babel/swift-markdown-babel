import Markdown

extension DocumentScope where Self: Document {
	@inlinable @inline(__always)
	public func map<Transformed>(
		_ transform: @escaping (Element) -> Transformed
	) -> MapDocument<Self, Transformed>
	where Transformed: Markdown.Markup {
		return MapDocument<Self, Transformed>(base: self, { transform($0 as! Element) })
	}
}
