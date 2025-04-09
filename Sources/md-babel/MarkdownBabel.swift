import ArgumentParser
import Foundation
import Markdown
import MarkdownBabel

@main
struct MarkdownBabel: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "md-babel",
		// abstract: String, usage: String?, discussion: String, version: String, shouldDisplay: Bool,
		subcommands: [Select.self, Execute.self],
		defaultSubcommand: nil
	)
}
