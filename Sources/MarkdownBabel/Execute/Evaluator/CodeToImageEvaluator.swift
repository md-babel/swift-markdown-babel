import Crypto

import struct Foundation.Data
import struct Foundation.URL

public struct CodeToImageEvaluator: Evaluator, Sendable {
	public let configuration: EvaluatorConfiguration
	public let generateImageFileURL: GenerateImageFileURL

	public init(configuration: EvaluatorConfiguration, generateImageFileURL: GenerateImageFileURL) {
		self.configuration = configuration
		self.generateImageFileURL = generateImageFileURL
	}

	public func run(_ code: String) async throws -> Execute.Response.ExecutionResult.Output {
		guard let hashContent = ContentHash(string: code, encoding: .utf8)
		else { throw ExecutionFailure.hashingContentFailed(code) }

		let (_, outputData) = try await runProcess(
			configuration: self.configuration,
			standardInput: code
		)

		let hash: String = hashContent()
		let filename = "rendered-" + hash  // TODO: Make filename pattern configurable https://github.com/md-babel/swift-markdown-babel/issues/20
		let imageURL: URL = generateImageFileURL(filename: filename)
		return .init(
			insert: .image(path: imageURL.path(), hash: hash),
			sideEffect: .writeFile(outputData, to: imageURL)
		)
	}
}
