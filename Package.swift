// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "MarkdownBlockRenderer",
	platforms: [
		.macOS(.v14)
	],
	dependencies: [
		.package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.5.0"),
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
	],
	targets: [
		.target(
			name: "MarkdownBlockRenderer",
			dependencies: [
				.product(name: "Markdown", package: "swift-markdown")
			]
		),
		.executableTarget(
			name: "render-mermaid",
			dependencies: [
				.target(name: "MarkdownBlockRenderer"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),
	]
)
