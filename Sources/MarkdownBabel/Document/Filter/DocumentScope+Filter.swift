import Markdown

extension DocumentScope where Self: Document {
	@inlinable @inline(__always)
	public func filter(_ predicate: @escaping (Element) -> Bool) -> FilterDocument<Self, Element> {
		return FilterDocument(base: self, { predicate($0) })
	}
}
