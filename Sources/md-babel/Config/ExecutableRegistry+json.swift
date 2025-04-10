import DynamicJSON

extension ExecutableRegistry {
	func json() throws -> JSON {
		return .object(try self.configurations.mapValues { try $0.json() })
	}
}
