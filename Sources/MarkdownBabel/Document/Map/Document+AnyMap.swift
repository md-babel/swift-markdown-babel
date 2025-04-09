extension Document {
	@_disfavoredOverload
	@inlinable @inline(__always)
	public func map(_ transform: @escaping (AnyElement) -> AnyElement) -> some Document {
		return AnyMapDocument(base: self, transform)
	}
}
