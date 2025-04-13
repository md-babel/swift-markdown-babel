import Crypto
import Foundation

public struct Evaluator: Sendable {
	public let configuration: EvaluatorConfiguration
	public let generateImageFileURL: GenerateImageFileURL

	public init(configuration: EvaluatorConfiguration, generateImageFileURL: GenerateImageFileURL) {
		self.configuration = configuration
		self.generateImageFileURL = generateImageFileURL
	}

	public func result(fromRunning code: String) async -> Execute.Response.ExecutionResult {
		do {
			let result = try await run(code: code)
			return .init(output: result, error: nil)
		} catch {
			return .init(output: nil, error: "\(error)")
		}
	}

	public func run(code: String) async throws -> Execute.Response.ExecutionResult.Output {
		let runProcess = configuration.makeRunProcess()
		let (result, outputData) = try await runProcess(input: code, additionalArguments: [])

		let terminationStatus: RunProcess.TerminationStatus =
			switch result {
			case .right(let error):
				throw ExecutionFailure.processExecutionFailed(error, result)
			case .left(let status):
				status
			}

		switch configuration.resultMarkupType {
		case .codeBlock:
			guard let code = String(data: outputData, encoding: .utf8)
			else { throw ExecutionFailure.processResultIsNotAString(outputData, terminationStatus) }
			return .init(
				insert: .codeBlock(language: "", code: code),
				sideEffect: nil
			)

		case .image:
			guard let hashContent = ContentHash(string: code, encoding: .utf8)
			else { throw ExecutionFailure.hashingContentFailed(code) }
			let hash: String = hashContent()
			let filename = "rendered-" + hash  // TODO: Make filename pattern configurable https://github.com/md-babel/swift-markdown-babel/issues/20
			let imageURL: URL = generateImageFileURL(filename: filename)
			return .init(
				insert: .image(path: imageURL.path(), hash: hash),
				sideEffect: .writeFile(outputData, to: imageURL)
			)
		}
	}
}
