import DynamicJSON
import Foundation

extension ExecutableConfiguration {
	private struct Representation: Codable {
		let path: String
		let defaultArguments: [String]
	}

	static func configurations(fromJSON json: JSON) throws -> [String: ExecutableConfiguration] {
		guard let object = json.objectValue else { throw JSON.Error.typeMismatch(.object, json) }
		return try object.mapValues { try ExecutableConfiguration(fromJSON: $0) }
	}

	static func configurations(jsonFileAtURL url: URL) throws -> [String: ExecutableConfiguration] {
		let data = try Data(contentsOf: url)
		let json = try JSON(data: data)
		return try ExecutableConfiguration.configurations(fromJSON: json)
	}

	init(fromJSON json: JSON) throws {
		let rep: Representation = try json.coerce()
		self.init(
			executableURL: URL(fileURLWithPath: rep.path),
			arguments: rep.defaultArguments
		)
	}

	func json() throws -> JSON {
		let rep = Representation(
			path: self.executableURL.path(),
			defaultArguments: self.arguments
		)
		return try JSON(encodable: rep)
	}
}
