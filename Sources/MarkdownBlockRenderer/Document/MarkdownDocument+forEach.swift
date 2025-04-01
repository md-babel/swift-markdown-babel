import Markdown

extension MarkdownDocument {
	/// Syntactic sugar for ``compactMap(_:)`` with a conditional cast to ``Target``.
	@inlinable @inline(__always)
	public func forEach<Target>(
		_ targetType: Target.Type
	) -> CompactMap<InitialDocument, Target>
	where Target: Markdown.Markup {
		return compactMap { $0 as? Target }
	}
}
