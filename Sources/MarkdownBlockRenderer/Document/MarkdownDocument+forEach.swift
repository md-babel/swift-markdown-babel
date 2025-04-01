import Markdown

extension MarkdownDocument {
	public func forEach<Target, Output>(
		_ selector: @escaping (Target) -> Output
	) -> MarkdownBlockSelector<Target, Output>
	where Target: Markdown.BlockMarkup {
		return MarkdownBlockSelector(document: self.document, visitor: selector)
	}

	public func forEach<Target>(
		_ targetType: Target.Type
	) -> MarkdownBlockSelector<Target, Target>
	where Target: Markdown.BlockMarkup {
		return MarkdownBlockSelector(document: self.document) { $0 }
	}
}

extension Markdown.Document {
	@usableFromInline
	func forEach<Target, Output>(
		_ selector: @escaping (Target) -> Output
	) -> MarkdownBlockSelector<Target, Output>
	where Target: Markdown.BlockMarkup {
		return MarkdownBlockSelector(document: self, visitor: selector)
	}

	@usableFromInline
	func forEach<Target>(
		_ targetType: Target.Type
	) -> MarkdownBlockSelector<Target, Target>
	where Target: Markdown.BlockMarkup {
		return MarkdownBlockSelector(document: self) { $0 }
	}
}
