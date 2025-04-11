import DynamicJSON
import Foundation
import MarkdownBabel

extension ExecutableConfiguration {
	struct Representation: Codable {
		let path: String
		let defaultArguments: [String]
		let result: String
	}

	static func configurations(fromJSON json: JSON) throws -> [String: ExecutableConfiguration] {
		guard let object = json.objectValue else { throw JSON.Error.typeMismatch(.object, json) }
		return try object.mapValues { try ExecutableConfiguration(fromJSON: $0) }
	}

	static func configurations(jsonFileAtURL url: URL) throws -> [String: [String: ExecutableConfiguration]] {
		let data = try Data(contentsOf: url)
		let json = try JSON(data: data)
		var result: [String: [String: ExecutableConfiguration]] = [:]
		result["codeBlock"] = try json["codeBlock"].map(ExecutableConfiguration.configurations(fromJSON:))
		return result
	}

	init(fromJSON json: JSON) throws {
		let rep: Representation = try json.coerce()
		let resultMarkupType: ResultMarkupType =
			switch rep.result {
			case "codeBlock": .codeBlock
			default: .codeBlock
			}
		self.init(
			executableURL: URL(fileURLWithPath: rep.path),
			arguments: rep.defaultArguments,
			resultMarkupType: resultMarkupType
		)
	}

	func json() throws -> JSON {
		let resultMarkupType =
			switch self.resultMarkupType {
			case .codeBlock: "codeBlock"
			}
		let rep = Representation(
			path: self.executableURL.path(),
			defaultArguments: self.arguments,
			result: resultMarkupType
		)
		return try JSON(encodable: rep)
	}
}
