import ArgumentParser
import Foundation
import Markdown
import MarkdownBlockRenderer

struct RenderError: Error, CustomStringConvertible {
	let message: String
	var description: String { "Rendering error: \(message)" }
}

// Supported image output formats as of mmdc v11.4.2.
let mermaidImageOutputFormats = ["svg", "png", "pdf"]
let defaultImageOutputFormat = "svg"

@main
struct RenderMermaid: AsyncParsableCommand {
	mutating func run() async throws {
		let render = MermaidRenderer(
			mermaidPath: mermaidPath,
			document: try markdownDocument(),
			outputDirectory: try await outputDirectory(),
			outputFileExtension: try fileExtension(),
			log: logger()
		)
		try await render()
	}

	// MARK: - Mermaid CLI path

	@Option(
		name: [.customShort("m"), .customLong("mermaid")],
		help: "Path to the mmdc executable."
	)
	var mermaidPath: String

	// MARK: - Input File

	@Option(
		name: [.customShort("i"), .customLong("input")],
		help: "Input file path.",
		transform: { URL(fileURLWithPath: $0) }
	)
	var inputFile: URL?

	func markdownDocument() throws -> MarkdownDocument {
		if let inputFile {
			return try MarkdownDocument(parsing: inputFile)
		} else if let string = readLine() {
			return MarkdownDocument(parsing: string)
		} else {
			// To test this, try to `readLine()` twice; the second one will fail because STDIN has already been emptied.
			throw RenderError(message: "Provide either non-empty STDIN or input file")
		}
	}

	// MARK: - Output Directory

	@Option(
		name: [.customShort("o"), .customLong("outdir")],
		help: "Output directory to create diagrams in."
	)
	var outputPath: String?

	func outputDirectory() async throws -> URL {
		guard let outputPath else {
			return try await makeTemporaryOutputDirectory()
		}
		return try directory(forPath: outputPath)
	}

	@MainActor
	private func makeTemporaryOutputDirectory() throws -> URL {
		let tmpDir = FileManager.default.temporaryDirectory

		try! VerboseLogger(isEnabled: self.verbose)
			.log("Using temporary directory: “\(tmpDir)”")

		do {
			try FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
			return tmpDir
		} catch let error {
			throw RenderError(message: "Could not create temporary directory at “\(tmpDir)”: \(error)")
		}
	}

	private func directory(forPath path: String) throws -> URL {
		var isDirectory: ObjCBool = false
		let pathExists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
		guard pathExists else {
			throw RenderError(message: "Output directory at “\(path)” does not exist")
		}
		guard isDirectory.boolValue == true else {
			throw RenderError(message: "Output path at “\(path)” is not a directory")
		}
		return URL(fileURLWithPath: path, isDirectory: true)
	}

	// MARK: - Output Format

	@Option(
		name: [.customShort("f"), .customLong("format")],
		help: "Image output format, one of \(mermaidImageOutputFormats)."
	)
	var format: String = defaultImageOutputFormat

	func fileExtension() throws -> String {
		let format = self.format.lowercased()
		guard mermaidImageOutputFormats.contains(format) else {
			throw RenderError(
				message: "Output format “\(format)” not recognized. Choices: \(mermaidImageOutputFormats)"
			)
		}
		return format
	}

	// MARK: - Verbosity

	@Flag(
		name: [.customShort("v"), .customLong("verbose")],
		help: "Print render status to standard output."
	)
	var verbose: Bool = false

	func logger() -> VerboseLogger {
		VerboseLogger(isEnabled: self.verbose)
	}
}
