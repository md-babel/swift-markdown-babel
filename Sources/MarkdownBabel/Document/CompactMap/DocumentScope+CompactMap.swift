import Markdown

extension DocumentScope where Self: Document {
	@inlinable @inline(__always)
	public func compactMap<OtherElement>(
		_ transform: @escaping (Element) -> OtherElement?
	) -> CompactMapDocument<Self, OtherElement>
	where OtherElement: Markdown.Markup {
		return CompactMapDocument<Self, OtherElement>(base: self, { transform($0 as! Element) })
	}
}
