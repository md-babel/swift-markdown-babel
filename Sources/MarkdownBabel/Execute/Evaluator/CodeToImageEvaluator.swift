import Crypto

import struct Foundation.Data
import struct Foundation.URL

public struct CodeToImageEvaluator: Evaluator, Sendable {
	public let configuration: EvaluatorConfiguration
	public let imageConfiguration: ImageEvaluationConfiguration
	public let generateImageFileURL: GenerateImageFileURL

	public init(configuration: EvaluatorConfiguration, generateImageFileURL: GenerateImageFileURL) {
		precondition({ if case .codeBlock = configuration.executableMarkupType { true } else { false } }())
		guard case .image(let imageConfiguration) = configuration.resultMarkupType else {
			preconditionFailure("Tried to initialize image evaluator with non-image configuration: \(configuration)")
		}
		self.configuration = configuration
		self.imageConfiguration = imageConfiguration
		self.generateImageFileURL = generateImageFileURL
	}

	public func run(
		_ code: String,
		sourceURL: URL?
	) async throws -> Execute.Response.ExecutionResult.Output {
		guard let hashContent = ContentHash(string: code, encoding: .utf8)
		else { throw ExecutionFailure.hashingContentFailed(code) }

		let (_, outputData) = try await runProcess(
			configuration: self.configuration,
			standardInput: code
		)

		let hash: String = hashContent()
		let sourceFilename = sourceURL?.deletingPathExtension().lastPathComponent ?? "STDIN"
		let filename = filename(
			pattern: imageConfiguration.filenamePattern,
			sourceFilename: sourceFilename,
			contentHash: hash
		)
		let imageURL: URL = generateImageFileURL(filename: filename, directory: imageConfiguration.directory)
		return .init(
			insert: .image(path: imageURL.absoluteURL.path, hash: hash),
			sideEffect: .writeFile(outputData, to: imageURL)
		)
	}
}
