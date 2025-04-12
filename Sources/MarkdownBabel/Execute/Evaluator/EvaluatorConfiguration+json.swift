import DynamicJSON
import Foundation

extension EvaluatorConfiguration {
	struct Representation: Codable {
		let path: String
		let defaultArguments: [String]
		let result: String
	}

	public static func codeBlockConfigurations(
		fromJSON json: JSON
	) throws -> [ExecutableMarkup: EvaluatorConfiguration] {
		guard let object = json.objectValue
		else { throw JSON.Error.typeMismatch(.object, json) }
		let configurations = try object.map { try EvaluatorConfiguration(codeBlockFromJSON: $1, language: $0) }
		return Dictionary(zip(configurations.map(\.executableMarkupType), configurations)) { _, new in new }
	}

	public static func configurations(jsonFileAtURL url: URL) throws -> [ExecutableMarkup: EvaluatorConfiguration] {
		let data = try Data(contentsOf: url)
		let json = try JSON(data: data)
		return try json["codeBlock"].map(EvaluatorConfiguration.codeBlockConfigurations(fromJSON:)) ?? [:]
	}

	init(codeBlockFromJSON json: JSON, language: String) throws {
		let rep: Representation = try json.coerce()
		self.init(
			executableURL: URL(fileURLWithPath: rep.path),
			arguments: rep.defaultArguments,
			executableMarkupType: .codeBlock(language: language),
			resultMarkupType: try EvaluationResultMarkup(string: rep.result)
		)
	}

	public func json() throws -> JSON {
		let resultMarkupType =
			switch self.resultMarkupType {
			case .codeBlock: "codeBlock"
			case .image: "image"
			}
		let rep = Representation(
			path: self.executableURL.path(),
			defaultArguments: self.arguments,
			result: resultMarkupType
		)
		return try JSON(encodable: rep)
	}
}
