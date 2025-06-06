import ArgumentParser
import DynamicJSON
import Foundation
import Markdown
import MarkdownBabel

struct ExecuteCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "execute",
		abstract: "Execute code blocks",
		aliases: ["exec"]
	)

	// MARK: - Input File

	@Option(
		name: [.customShort("f"), .customLong("file")],
		help: "File to execute code block in, instead of standard input.",
		transform: { URL(fileURLWithPath: $0) }
	)
	var inputFile: URL?

	@Option(
		name: .customLong("filename"),
		help: "Surrogate filename of the document, used in filename generators and references."
	)
	var filename: String?

	func markdownDocument() throws -> MarkdownDocument {
		if let inputFile {
			return try MarkdownDocument(parsing: inputFile)
		} else if let string = try stringFromStdin() {
			return MarkdownDocument(parsing: string, file: filename.map(File.init(filename:)) ?? .standardInput)
		} else {
			// To test this, try to `readLine()` twice; the second one will fail because STDIN has already been emptied.
			throw GenericError(message: "Provide either non-empty STDIN or input file")
		}
	}

	// MARK: - Location

	@Option(
		name: .shortAndLong,
		help: "Line position of the insertion point in file. (1-based)",
		transform: positiveNonZero(_:)
	)
	var line: Int
	@Option(
		name: .shortAndLong,
		help: "Column position of the insertion point in file at line. (1-based)",
		transform: positiveNonZero(_:)
	)
	var column: Int

	func sourceLocation() throws -> Markdown.SourceLocation {
		Markdown.SourceLocation(line: line, column: column, source: inputFile)
	}

	// MAR: - Working directory

	@Option(
		name: [.customShort("d"), .customLong("dir")],
		help: ArgumentHelp(
			"Working directory used to resolve relative paths.",
			discussion:
				"""
				Compiler and image generator configurations can use relative paths to put build
				artifacts and assets there, respectively. In large writing projects, set this to
				the project root. Defaults to a temporary directory if unset.
				""",
			valueName: "/path/to/project"
		)
	)
	var workingDirectoryPath: String?

	@Flag(
		name: .customLong("relative-paths"),
		inversion: .prefixedNo,
		exclusivity: .exclusive,
		help: "Whether to use relative paths when possible."
	)
	var allowsRelativePaths = true

	var produceRelativePaths: Bool { allowsRelativePaths && workingDirectoryPath != nil }

	// MARK: - Config File

	@Option(
		name: .customLong("config"),
		help: "Config file path.",
		transform: { URL(fileURLWithPath: $0) }
	)
	var configFile: URL?

	@Flag(
		name: .customLong("load-user-config"),
		inversion: .prefixedNo,
		exclusivity: .exclusive,
		help: ArgumentHelp(
			"Whether to load the user's global config file.",
			discussion:
				"""
				Note: If you use --no-load-user-config, you should set
				--config to recognize any code block language at all.
				"""
		)
	)
	var loadUserConfig = true

	func evaluatorRegistry() throws -> EvaluatorRegistry {
		return try EvaluatorRegistry.load(fromXDG: self.loadUserConfig, fromFile: configFile)
	}

	// MARK: - Run

	func run() async throws {
		let document = try markdownDocument()
		let location = try sourceLocation()
		guard let context = document.executableContext(at: location) else {
			// TODO: Produce "nothing found" response. https://github.com/md-babel/swift-markdown-babel/issues/15
			FileHandle.standardOutput.write(try JSON.object([:]).data())
			return
		}
		let configuration = try evaluatorRegistry().configuration(forCodeBlock: context.codeBlock)
		let evaluator = configuration.makeEvaluator(
			outputDirectory: try outputDirectory(),
			produceRelativePaths: produceRelativePaths
		)
		let execute = Execute(executableContext: context, evaluator: evaluator)
		let response = await execute()

		try perform(sideEffect: response.executionResult.output?.sideEffect)

		let data =
			try json(response, originalLocation: location)
			.data(formatting: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
		FileHandle.standardOutput.write(data)
	}
}

extension ExecuteCommand {
	func outputDirectory() throws(EvaluatorRegistryFailure) -> URL {
		guard let workingDirectoryPath else {
			return try makeTemporaryOutputDirectory()
		}
		return try directory(forPath: workingDirectoryPath)
	}

	private func makeTemporaryOutputDirectory() throws(EvaluatorRegistryFailure) -> URL {
		let tmpDir = FileManager.default.temporaryDirectory

		do {
			try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
			return tmpDir
		} catch let error {
			throw .directoryLookupFailed("Could not create temporary directory at “\(tmpDir)”: \(error)")
		}
	}

	private func directory(forPath path: String) throws(EvaluatorRegistryFailure) -> URL {
		var isDirectory: ObjCBool = false
		let pathExists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
		guard pathExists else {
			throw .directoryLookupFailed("Output directory at “\(path)” does not exist")
		}
		guard isDirectory.boolValue == true else {
			throw .directoryLookupFailed("Output path at “\(path)” is not a directory")
		}
		return URL(fileURLWithPath: path, isDirectory: true)
	}
}

func perform(sideEffect: SideEffect?) throws {
	switch sideEffect {
	case .writeFile(let data, let url):
		try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
		try data.write(to: url)
	case .none:
		break
	}
}

func json(_ response: Execute.Response, originalLocation location: SourceLocation) -> JSON {
	let renderedString = response.rendered()
	var jsonResult: [String: JSON] = [
		"range": json(location..<location),
		"replacementRange": json(response.executableContext.encompassingRange),
		"replacementString": .string(renderedString),
	]
	if let output = response.executionResult.output {
		jsonResult["result"] = .string(output.insert.stringContent)
	}
	if let error = response.executionResult.error {
		jsonResult["error"] = .string(error)
	}
	return .object(jsonResult)
}
