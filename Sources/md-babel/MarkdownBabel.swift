import ArgumentParser
import Foundation
import Markdown
import MarkdownBlockRenderer

@main
struct MarkdownBabel: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "md-babel",
		// abstract: String, usage: String?, discussion: String, version: String, shouldDisplay: Bool,
		subcommands: [Select.self],
		defaultSubcommand: nil
	)
}
