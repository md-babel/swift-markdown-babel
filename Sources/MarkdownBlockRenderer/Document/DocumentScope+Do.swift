import Markdown

extension DocumentScope where Self: Document {
	@inlinable @inline(__always)
	public func `do`(
		_ sink: @escaping (Element) -> Void
	) -> Self.VisitedDocument {
		return self.markdown { element in
			sink(element as! Element)
			return element
		}
	}

	@inlinable @inline(__always)
	public func `do`(
		_ sink: @escaping (Element) throws -> Void
	) throws -> Self.VisitedDocument {
		var error: (any Error)?

		let result = self.markdown { element in
			guard error == nil else { return element }
			do {
				try sink(element as! Element)
			} catch let e {
				error = e
			}
			return element
		}

		if let error {
			throw error
		}

		return result
	}
}
