import DynamicJSON
import Foundation
import MarkdownBabel

extension ExecutableConfiguration {
	struct Representation: Codable {
		let path: String
		let defaultArguments: [String]
		let result: String
	}

	static func codeBlockConfigurations(
		fromJSON json: JSON
	) throws -> [ResultMarkupType: ExecutableConfiguration] {
		guard let object = json.objectValue
		else { throw JSON.Error.typeMismatch(.object, json) }
		let configurations = try object.map { try ExecutableConfiguration(codeBlockFromJSON: $1, language: $0) }
		return Dictionary(zip(configurations.map(\.resultMarkupType), configurations)) { _, new in new }
	}

	static func configurations(jsonFileAtURL url: URL) throws -> [ResultMarkupType: ExecutableConfiguration] {
		let data = try Data(contentsOf: url)
		let json = try JSON(data: data)
		return try json["codeBlock"].map(ExecutableConfiguration.codeBlockConfigurations(fromJSON:)) ?? [:]
	}

	init(codeBlockFromJSON json: JSON, language: String) throws {
		let rep: Representation = try json.coerce()
		self.init(
			executableURL: URL(fileURLWithPath: rep.path),
			arguments: rep.defaultArguments,
			resultMarkupType: .codeBlock(language: language)
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
