import Foundation
import Markdown
import MarkdownBlockRenderer

struct MermaidRenderer {
	let mermaidPath: String
	let document: MarkdownDocument
	let outputDirectory: URL
	let outputFileExtension: String
	let log: VerboseLogger

	init(
		mermaidPath: String,
		document: consuming MarkdownDocument,
		outputDirectory: URL,
		outputFileExtension: String,
		log: VerboseLogger
	) {
		self.mermaidPath = mermaidPath
		self.document = document
		self.outputDirectory = outputDirectory
		self.outputFileExtension = outputFileExtension
		self.log = log
	}

	func callAsFunction() async throws {
		try await render()
	}

	struct MermaidRenderError: Error {
		let code: String
		let targetURL: URL
		let wrapped: (any Error)?
	}

	func render() async throws {
		let renderer = MarkdownBlockRenderer<Markdown.CodeBlock, String>(
			outputDirectory: outputDirectory,
			fileExtension: outputFileExtension
		) { (code: String, url: URL) throws in
			let path = url.path(percentEncoded: false)
			let stdin = try Pipe.stdin(string: code)
			let stdout = Pipe()
			let stderr = Pipe()
			let process = Process()
			process.executableURL = URL(fileURLWithPath: mermaidPath)
			process.arguments = [
				"-i", "-",
				"-o", path,
			]
			process.standardInput = stdin
			process.standardError = stderr
			process.standardOutput = stdout

			defer {
				if log.isEnabled {
					let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
					try? FileHandle.standardOutput.write(contentsOf: outputData)
				}
			}

			do {
				try process.run()
				process.waitUntilExit()

				if process.terminationStatus != 0 {
					let stderrMessage = String(
						data: stderr.fileHandleForReading.readDataToEndOfFile(),
						encoding: .utf8
					)
					throw RenderError(
						message: stderrMessage ?? "Process terminated with exit code \(process.terminationStatus)"
					)
				}
			} catch {
				throw MermaidRenderError(
					code: code,
					targetURL: url,
					wrapped: error
				)
			}
		}

		var deltas: [Delta] = []

		_ =
			try document
			.compactMap { $0 as? Markdown.CodeBlock }
			.filter { $0.language?.lowercased() == "mermaid" }
			.do { (codeBlock: Markdown.CodeBlock) in
				guard let replacementRange = codeBlock.range
				else { preconditionFailure("Applying modifications to generated elements") }

				let file = try renderer.render(codeBlock, \Markdown.CodeBlock.code)
				let delta = Markdown.Document(
					codeBlock,
					Paragraph(
						Image(source: file.path(), title: nil)
					)
				)

				deltas.append(Delta(replacementRange: replacementRange, replacementDocument: delta))
			}
			.markdown()

		// MARK: - Insert into UTF-8

		let utf8 = document.string.utf8
		let lines = utf8.split(omittingEmptySubsequences: false, whereSeparator: isNewline(_:))

		func toUTF8(_ sourceLocation: SourceLocation) -> String.UTF8View.Index {
			// TODO: reuse and advance the previous iteration's index to make this O(n), not O(n*n*2)
			let lineIndex = lines[sourceLocation.line - 1].startIndex
			return utf8.index(lineIndex, offsetBy: sourceLocation.column - 1)
		}

		var applicableDeltas: [ApplicableDelta] = []
		for delta in deltas {
			// TODO: reuse and advance the previous iteration's index to make this O(n), not O(n*n)
			let utf8Range: Range<String.UTF8View.Index> =
				(toUTF8(delta.replacementRange.lowerBound)..<toUTF8(delta.replacementRange.upperBound))
			let applicable = ApplicableDelta(delta: delta, utf8Range: utf8Range)
			applicableDeltas.append(applicable)
		}

		var newString = document.string
		for applicableDelta
			in applicableDeltas
			.sorted(by: { $0.utf8Range.lowerBound < $1.utf8Range.lowerBound })
			.reversed()
		{
			let renderedString = applicableDelta.delta.replacementDocument.format(options: .default)
			// TODO: replace this very costly range conversion
			print(applicableDelta.utf8Range)
			let stringRange =
				applicableDelta.utf8Range.lowerBound.samePosition(in: document.string)!..<applicableDelta.utf8Range
				.upperBound.samePosition(in: document.string)!
			newString.replaceSubrange(stringRange, with: renderedString)
		}
		print(newString)
	}
}

struct Delta {
	let replacementRange: Markdown.SourceRange
	let replacementDocument: Markdown.Document
}

struct ApplicableDelta {
	let delta: Delta
	let utf8Range: Range<String.UTF8View.Index>
}

func isNewline(_ codeUnit: String.UTF8View.Element) -> Bool {
	return codeUnit == String.UTF8View.Element(ascii: "\n") || codeUnit == String.UTF8View.Element(ascii: "\r")
}
