import DynamicJSON
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
}
