// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "swift-markdown-babel",
	platforms: [
		.macOS(.v14)
	],
	products: [
		.executable(name: "md-babel", targets: ["md-babel"])
	],
	dependencies: [
		.package(url: "https://github.com/apple/swift-crypto.git", "1.0.0"..<"4.0.0"),  // CryptoKit drop-in replacement for hashing
		.package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.5.0"),
		.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.0"),
	],
	targets: [
		.target(
			name: "MarkdownBabel",
			dependencies: [
				.product(name: "Markdown", package: "swift-markdown"),
				.product(name: "Crypto", package: "swift-crypto"),
			]
		),
		.testTarget(
			name: "MarkdownBabelTests",
			dependencies: [.target(name: "MarkdownBabel")]
		),

		.executableTarget(
			name: "md-babel",
			dependencies: [
				.target(name: "MarkdownBabel"),
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),
		.testTarget(
			name: "md-babel-tests",
			dependencies: [.target(name: "md-babel")]
		),
	]
)
