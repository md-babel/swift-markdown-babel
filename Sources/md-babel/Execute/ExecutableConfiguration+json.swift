import DynamicJSON
import Foundation

extension ExecutableConfiguration {
	private struct Representation: Decodable {
		let path: String
		let defaultArguments: [String]
	}

	init(fromJSON json: JSON) throws {
		let rep: Representation = try json.coerce()
		self.init(
			executableURL: URL(fileURLWithPath: rep.path),
			arguments: rep.defaultArguments
		)
	}

	static func configurations(fromJSON json: JSON) throws -> [String: ExecutableConfiguration] {
		guard let object = json.objectValue else { throw JSON.Error.typeMismatch(.object, json) }
		return try object.mapValues { try ExecutableConfiguration(fromJSON: $0) }
	}
}
