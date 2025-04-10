import ArgumentParser
import Foundation

struct ConfigCommand: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "config",
		subcommands: [DumpCommand.self],
		// defaultSubcommand: DumpCommand.self,
		aliases: ["configure", "configuration"]
	)
}

extension ConfigCommand {
	struct DumpCommand: ParsableCommand {
		static let configuration = CommandConfiguration(
			commandName: "dump",
			abstract: "Inspect your effective configuration"
		)

		// MARK: - Config File

		@Option(
			name: .customLong("config"),
			help: "Config file path.",
			transform: { URL(fileURLWithPath: $0) }
		)
		var configFile: URL?

		func executableRegistry() throws -> ExecutableRegistry {
			let xdgConfigURL = FileManager.default.homeDirectoryForCurrentUser
				.appending(path: ".config", directoryHint: .isDirectory)
				.appending(path: "md-babel", directoryHint: .isDirectory)
				.appending(path: "config", directoryHint: .notDirectory)
				.appendingPathExtension("json")
			let fromXDG = (try? ExecutableConfiguration.configurations(jsonFileAtURL: xdgConfigURL)) ?? [:]
			let fromFile = try configFile.map(ExecutableConfiguration.configurations(jsonFileAtURL:)) ?? [:]

			var configurations: [String: ExecutableConfiguration] = [:]
			configurations.merge(fromXDG) { _, new in new }
			configurations.merge(fromFile) { _, new in new }

			return ExecutableRegistry(configurations: configurations)
		}

		func run() throws {
			let registry = try executableRegistry()
			let json = try registry.json()
			let data = try json.data(formatting: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
			FileHandle.standardOutput.write(data)
		}
	}
}
