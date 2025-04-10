import ArgumentParser
import Foundation
import Markdown
import MarkdownBabel

@main
struct MarkdownBabelCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "md-babel",
		// abstract: String, usage: String?, discussion: String, version: String, shouldDisplay: Bool,
		subcommands: [ExecuteCommand.self, SelectCommand.self, ConfigCommand.self],
		defaultSubcommand: nil
	)
}
