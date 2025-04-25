// swift-format-ignore-file: AlwaysUseLowerCamelCase
import DynamicJSON
import Foundation
import MarkdownBabel
import Testing

@Suite struct EvaluatorConfigurationTests {
	@Test func duplicateCodeBlockEvaluatorKeys_FirstOneWins() throws {
		let jsonString =
			"""
			{
			  "sh": {
			    "path": "/usr/bin/env",
			    "defaultArguments": ["bash"],
			    "result": "codeBlock"
			  },
			  "sh": {
			    "path": "/usr/bin/env",
			    "defaultArguments": ["zsh"],
			    "result": "codeBlock"
			  },
			}
			"""
		let json = try JSON(string: jsonString)
		let config = try EvaluatorConfiguration.codeBlockConfigurations(fromJSON: json)
		#expect(
			config == [
				.codeBlock(language: "sh"): EvaluatorConfiguration(
					executablePath: "/usr/bin/env",
					arguments: ["bash"],
					executableMarkupType: .codeBlock(language: "sh"),
					resultMarkupType: .codeBlock
				)
			]
		)
	}

	@Test func sampleEvaluators() throws {
		let jsonString =
			"""
			{
			  "sh": {
			    "path": "/usr/bin/env",
			    "defaultArguments": ["sh"],
			    "result": "codeBlock"
			  },
			  "dot": {
			    "path": "/usr/bin/env",
			    "defaultArguments": ["dot", "-Tsvg"],
			    "result": {
			      "type": "image",
			      "directory": "/tmp/dir",
			      "filename": "a filename pattern",
			      "extension": "svg"
			    }
			  },
			  "python": {
			    "path": "/usr/bin/env",
			    "defaultArguments": ["python3"],
			    "result": "codeBlock"
			  },
			}
			"""
		let json = try JSON(string: jsonString)
		let config = try EvaluatorConfiguration.codeBlockConfigurations(fromJSON: json)
		#expect(
			config == [
				.codeBlock(language: "sh"): EvaluatorConfiguration(
					executablePath: "/usr/bin/env",
					arguments: ["sh"],
					executableMarkupType: .codeBlock(language: "sh"),
					resultMarkupType: .codeBlock
				),
				.codeBlock(language: "dot"): EvaluatorConfiguration(
					executablePath: "/usr/bin/env",
					arguments: ["dot", "-Tsvg"],
					executableMarkupType: .codeBlock(language: "dot"),
					resultMarkupType: .image(
						fileExtension: "svg",
						directory: "/tmp/dir",
						filenamePattern: "a filename pattern"
					)
				),
				.codeBlock(language: "python"): EvaluatorConfiguration(
					executablePath: "/usr/bin/env",
					arguments: ["python3"],
					executableMarkupType: .codeBlock(language: "python"),
					resultMarkupType: .codeBlock
				),
			]
		)
	}

	@Suite("makeEvaluator") struct MakeEvaluator {
		@Test func codeToCode() throws {
			let configuration = EvaluatorConfiguration(
				executableURL: URL(filePath: "/file/path"),
				arguments: ["a", "b"],
				executableMarkupType: .codeBlock(language: "input"),
				resultMarkupType: .codeBlock
			)
			let baseDir = URL(filePath: "/out/dir/")
			let evaluator = try #require(
				configuration.makeEvaluator(
					outputDirectory: baseDir,
					relativizePaths: false  // Irrelevant/unused in this evaluator
				) as? CodeToCodeEvaluator
			)
			#expect(evaluator.executableURL == URL(filePath: "/file/path"))
			#expect(evaluator.defaultArguments == ["a", "b"])
		}

		@Test(arguments: [
			true,
			false,
		]) func codeToImage(relativizePaths: Bool) throws {
			let imageConfig = ImageEvaluationConfiguration(
				fileExtension: "tiff",
				directory: "./subdir/",
				filenamePattern: "yyyyMM--'file'"
			)
			let configuration = EvaluatorConfiguration(
				executableURL: URL(filePath: "/path/to/converter"),
				arguments: ["x", "y"],
				executableMarkupType: .codeBlock(language: "graphics"),
				resultMarkupType: .image(imageConfig)
			)
			let baseDir = URL(filePath: "/out/dir/")
			let evaluator = try #require(
				configuration.makeEvaluator(
					outputDirectory: baseDir,
					relativizePaths: relativizePaths
				) as? CodeToImageEvaluator
			)
			let expectedGenerator = GenerateImageFileURL(
				outputDirectory: baseDir,
				relativizePaths: relativizePaths
			)
			#expect(evaluator.imageConfiguration == imageConfig)
			#expect(evaluator.generateImageFileURL == expectedGenerator)
			#expect(evaluator.executableURL == URL(filePath: "/path/to/converter"))
			#expect(evaluator.defaultArguments == ["x", "y"])
		}
	}
}
