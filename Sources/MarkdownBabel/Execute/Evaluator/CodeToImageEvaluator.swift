import Crypto

import struct Foundation.Data
import struct Foundation.URL

public struct CodeToImageEvaluator: Evaluator, Sendable {
	let runProcess: RunProcess
	public var executableURL: URL { runProcess.executableURL }
	public var defaultArguments: [String] { runProcess.defaultArguments }

	public let imageConfiguration: ImageEvaluationConfiguration
	public let generateImageFileURL: GenerateImageFileURL

	init(
		runProcess: RunProcess,
		imageConfiguration: ImageEvaluationConfiguration,
		generateImageFileURL: GenerateImageFileURL
	) {
		self.runProcess = runProcess
		self.imageConfiguration = imageConfiguration
		self.generateImageFileURL = generateImageFileURL
	}

	public func run(
		_ executableContext: ExecutableContext,
		sourceURL: URL?
	) async throws -> Execute.Response.ExecutionResult.Output {
		let code = executableContext.codeBlock.code

		guard let contentHash = ContentHash(string: code, encoding: .utf8)?.contentHash()
		else { throw ExecutionFailure.hashingContentFailed(code) }

		if let existingImageResult = executableContext.result?.content as? ImageResult,
			contentHash == existingImageResult.contentHash
		{
			return .init(
				insert: .image(path: existingImageResult.source, hash: existingImageResult.contentHash),
				sideEffect: nil
			)
		}

		let (_, outputData) = try await runProcess(input: code, additionalArguments: [])

		let sourceFilename = sourceURL?.deletingPathExtension().lastPathComponent ?? "STDIN"
		let filename = filename(
			pattern: imageConfiguration.filenamePattern,
			sourceFilename: sourceFilename,
			contentHash: contentHash
		)
		let imageURL: URL = generateImageFileURL(filename: filename, imageConfiguration: imageConfiguration)
		return .init(
			insert: .image(path: imageURL.absoluteURL.path, hash: contentHash),
			sideEffect: .writeFile(outputData, to: imageURL)
		)
	}
}
