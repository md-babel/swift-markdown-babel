import MarkdownBlockRenderer

/// Transformer to start a transformer chain with a single value without having to parse a document.
struct Just<Value>: Transformer {
	typealias From = Value
	typealias To = Value

	let value: Value

	init(_ value: Value) {
		self.value = value
	}

	func pipe(to sink: NonThrowingSink<Value>) {
		sink(value)
	}

	func pipe(to sink: ThrowingSink<Value>) throws {
		try sink(value)
	}
}
