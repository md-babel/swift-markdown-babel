import DynamicJSON
import Foundation
import MarkdownBabel

extension ExecutableRegistry {
	typealias Configurations = [ExecutableConfiguration.ResultMarkupType: [String: ExecutableConfiguration]]

	static func load(
		fromXDG loadFromXDG: Bool,
		fromFile fileURL: URL?
	) throws -> ExecutableRegistry {
		let xdgSource: Configurations =
			if loadFromXDG {
				(try? ExecutableConfiguration.configurations(jsonFileAtURL: xdgConfigURL)) ?? [:]
			} else {
				[:]
			}
		let fileSource: Configurations = try fileURL.map(ExecutableConfiguration.configurations(jsonFileAtURL:)) ?? [:]

		var configurations: Configurations = [
			.codeBlock: [:]
		]
		for (type, var configsForType) in configurations {
			for source in [xdgSource, fileSource] {
				guard let matchingConfigs = source[type] else { continue }
				configsForType.merge(matchingConfigs) { _, new in new }
			}
			configurations[type] = configsForType
		}

		return ExecutableRegistry(codeBlockConfigurations: configurations[.codeBlock, default: [:]])
	}

	func json() throws -> JSON {
		return .object([
			"codeBlock": .object(try self.codeBlockConfigurations.mapValues { try $0.json() })
		])
	}
}
