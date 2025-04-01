import MarkdownBlockRenderer

func collect<T>(_ block: () -> T) -> [T.To] where T: Transformer {
	var results: [T.To] = []
	block().do { results.append($0) }
	return results
}
