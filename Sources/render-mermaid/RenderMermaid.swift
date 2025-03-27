import ArgumentParser
import Foundation
import Markdown
import MarkdownBlockRenderer

extension Pipe {
	static func stdin(string: String) throws -> Pipe {
		let stdin = Pipe()
		try stdin.fileHandleForWriting.write(contentsOf: string.data())
		try stdin.fileHandleForWriting.close()
		return stdin
	}
}

struct RenderError: Error {
	let message: String
}

@main
struct RenderMermaid: AsyncParsableCommand {
	@Option(
		name: [.customShort("m"), .customLong("mermaid")],
		help: "Path to the mmdc executable."
	)
	var mermaidPath: String

	@Option(
		name: [.customShort("i"), .customLong("input")],
		help: "Input file path.",
		transform: { URL(fileURLWithPath: $0) }
	)
	var inputFile: URL?

	@Flag(
		name: [.customShort("v"), .customLong("verbose")],
		help: "Print render status to standard output."
	)
	var verbose: Bool = false

	@Option(
		name: [.customShort("o"), .customLong("outdir")],
		help: "Output directory to create diagrams in."
	)
	var outputPath: String?

	func log(_ string: @autoclosure () -> String) {
		guard verbose else { return }
		try! FileHandle.standardOutput.write(string().data())
	}

	func markdownDocument() throws -> Markdown.Document {
		if let inputFile {
			return try Document(parsing: inputFile)
		} else if let string = readLine() {
			return Document(parsing: string)
		} else {
			throw ArgumentParser.ValidationError(
				"Provide either STDIN or \(_inputFile.description)")
		}
	}

	func outputDirectory() throws -> URL {
		if let outputPath {
			return try directory(forPath: outputPath)
		} else {
			return try temporaryOutputDirectory()
		}
	}

	private func temporaryOutputDirectory() throws -> URL {
		let tmpDir = FileManager.default.temporaryDirectory

		log("Using temporary directory: “\(tmpDir)”")

		do {
			try FileManager.default.createDirectory(
				at: tmpDir, withIntermediateDirectories: true)
			return tmpDir
		} catch let error {
			throw RenderError(
				message: "Could not create temporary directory at “\(tmpDir)”: \(error)")
		}
	}

	private func directory(forPath path: String) throws -> URL {
		var isDirectory: ObjCBool = false
		let pathExists = FileManager.default.fileExists(
			atPath: path, isDirectory: &isDirectory)
		guard pathExists else {
			throw RenderError(message: "Output directory at “\(path)” does not exist")
		}
		guard isDirectory.boolValue == true else {
			throw RenderError(message: "Output path at “\(path)” is not a directory")
		}
		return URL(fileURLWithPath: path, isDirectory: true)
	}

	mutating func run() async throws {
		let document = try markdownDocument()
		let mermaidPath = self.mermaidPath
		let renderer = MarkdownBlockRenderer<Markdown.CodeBlock, String>(
			outputDirectory: try outputDirectory(),
			fileExtension: "png",
			extractContent: \.code
		) { [verbose] (code: String, url: URL) in
			let path = url.path(percentEncoded: false)
			let stdin = try Pipe.stdin(string: code)
			let stdout = Pipe()
			let process = Process()
			process.executableURL = URL(fileURLWithPath: mermaidPath)
			process.arguments = [
				"-i", "-",
				"-o", path,
			]
			process.standardInput = stdin
			process.standardError = FileHandle.standardError
			process.standardOutput = stdout
			try process.run()

			if verbose {
				let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
				try FileHandle.standardOutput.write(contentsOf: outputData)
			}
		}

		let files = try await renderer.renderedFiles(document: document)

		print(files)
	}
}
