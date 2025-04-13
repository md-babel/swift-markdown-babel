import Foundation
import Markdown

extension EvaluatorRegistry {
	func evaluator(
		forCodeBlock codeBlock: Markdown.CodeBlock
	) throws(EvaluatorRegistryFailure) -> Evaluator {
		let configuration = try configuration(forCodeBlock: codeBlock)
		return Evaluator(
			configuration: configuration,
			generateImageFileURL: GenerateImageFileURL(
				outputDirectory: try outputDirectory(),
				fileExtension: "svg"  // TODO: Make file extension configurable in converter https://github.com/md-babel/swift-markdown-babel/issues/20
			)
		)
	}
}

extension EvaluatorRegistry {
	func outputDirectory(
		outputPath: String? = nil
	) throws(EvaluatorRegistryFailure) -> URL {
		guard let outputPath else {
			return try makeTemporaryOutputDirectory()
		}
		return try directory(forPath: outputPath)
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
