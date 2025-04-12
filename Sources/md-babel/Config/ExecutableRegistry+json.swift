import DynamicJSON
import Foundation
import MarkdownBabel

extension EvaluatorRegistry {
	static func load(
		fromXDG loadFromXDG: Bool,
		fromFile fileURL: URL?
	) throws -> EvaluatorRegistry {
		let xdgSource: Configurations =
			if loadFromXDG {
				(try? EvaluatorConfiguration.configurations(jsonFileAtURL: xdgConfigURL)) ?? [:]
			} else {
				[:]
			}
		let fileSource: Configurations = try fileURL.map(EvaluatorConfiguration.configurations(jsonFileAtURL:)) ?? [:]

		var configurations: Configurations = [:]
		for source in [xdgSource, fileSource] {
			configurations.merge(source) { _, new in new }
		}

		return EvaluatorRegistry(configurations: configurations)
	}

	func json() throws -> JSON {
		let codeBlockConfigs = try self.configurations
			.compactMap { (key, config) in
				return if case .codeBlock(let language) = key {
					(language, try config.json())
				} else {
					nil
				}
			}
		return .object([
			"codeBlock": .object(Dictionary(codeBlockConfigs) { _, new in new })
		])
	}
}
