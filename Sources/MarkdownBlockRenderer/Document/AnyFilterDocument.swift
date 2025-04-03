import Markdown

/// Forward filter operator.
///
/// Does not actually remove any markup element from the base document, but affects what subsequent operators can access.
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
			guard predicate(element) else {
				// Forward original element (to not remove it from the output document), but don't apply downstream `visitor` to hide the element from it.
				return element
			}
			return visitor(element)
		})
	}

	public func markdown() -> Markdown.Document {
		// Pass all elements along, do not skip any in the actual output. Boils down to:
		//
		//     .markdown(visitor: { element in
		//         guard predicate(element) else { return element }
		//         return element
		//     })
		//
		// which just forwards element in both case, and can be skipped.
		return base.markdown()
	}
}

extension Document {
	@_disfavoredOverload
	@inlinable @inline(__always)
	public func filter(_ predicate: @escaping (AnyElement) -> Bool) -> some Document {
		return AnyFilterDocument(base: self, predicate)
	}
}
