import DynamicJSON
import Foundation

extension EvaluatorConfiguration {
	struct Representation: Codable {
		let path: String
		let defaultArguments: [String]
		let result: Either<String, [String: String]>
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
		return try json["evaluators"]?["codeBlock"].map(EvaluatorConfiguration.codeBlockConfigurations(fromJSON:))
			?? [:]
	}

	init(codeBlockFromJSON json: JSON, language: String) throws {
		let rep: Representation = try json.coerce()

		let resultMarkupType: EvaluationResultMarkup
		switch rep.result {
		case .left("codeBlock"):
			resultMarkupType = .codeBlock
		case .right(let dictionary) where dictionary["type"] == "image":
			resultMarkupType = .image(
				fileExtension: try dictionary.ensureValue("extension"),
				directory: dictionary["directory"],
				filenamePattern: try dictionary.ensureValue("filename")
			)
		default:
			throw UnrecognizedEvaluationResult(type: rep.result)
		}

		self.init(
			executableURL: URL(fileURLWithPath: rep.path),
			arguments: rep.defaultArguments,
			executableMarkupType: .codeBlock(language: language),
			resultMarkupType: resultMarkupType
		)
	}

	public func json() throws -> JSON {
		let resultMarkupType: Either<String, [String: String]> =
			switch self.resultMarkupType {
			case .codeBlock: .left("codeBlock")
			case .image(let config):
				.right(
					[
						"type": "image",
						"extension": config.fileExtension,
						"directory": config.directory,
						"filename": config.filenamePattern,
					].compactMapValues { $0 }
				)
			}
		let rep = Representation(
			path: self.executableURL.path(),
			defaultArguments: self.arguments,
			result: resultMarkupType
		)
		return try JSON(encodable: rep)
	}
}

extension Dictionary where Key: Sendable, Value: Sendable {
	public struct DictionaryKeyMissing: Error {
		public let key: Key
		public let dictionary: [Key: Value]

		public init(key: Key, dictionary: [Key: Value]) {
			self.key = key
			self.dictionary = dictionary
		}
	}

	func ensureValue(_ key: Self.Key) throws -> Self.Value {
		guard let value = self[key] else { throw DictionaryKeyMissing(key: key, dictionary: self) }
		return value
	}
}
