import MarkdownBabel
import Testing

import struct Foundation.URL

extension URL {
	/// Programmatic URL initialization from string literals. Raises exception when this fails, as a programmer error.
	fileprivate init(_ staticString: StaticString) {
		guard let url = URL(string: "\(staticString)") else {
			preconditionFailure("URL could not be created from string literal \(staticString)")
		}
		self = url
	}
}

@Suite("RelativeURLResolving")
struct RelativeURLResolvingTests {
	@Suite("Web URLs") struct WebURLTests {
		@Test func resolvesFolderRelativeToRoot() {
			#expect(
				URL("https://example.com/folder/index.html")
					.relativePath(resolvedAgainst: URL("https://example.com/root.txt")) == "folder/index.html"
			)
		}

		@Test("Nothing in common except scheme and domain")
		func nothingInCommonExceptSchemeAndDomain() {
			#expect(
				URL("https://example.com/index.html")
					.relativePath(resolvedAgainst: URL("https://example.com/path/file.txt")) == "/index.html"
			)
		}

		@Test("Detecting common root as shared parent path")
		func detectingCommonRootAsSharedParentPath() {
			#expect(
				URL("https://example.com/index.html")
					.relativePath(resolvedAgainst: URL("https://example.com/")) == "index.html"
			)
		}

		@Test
		func resolvesIndexInSameDirectory() {
			#expect(
				URL("https://example.com/path/index.html")
					.relativePath(resolvedAgainst: URL("https://example.com/path/other.html")) == "index.html"
			)
		}

		@Test("Same path is irrelevant if host doesn't match")
		func samePathIsIrrelevantIfHostDoesntMatch() {
			#expect(
				URL("https://example.com/index.html")
					.relativePath(resolvedAgainst: URL("https://different.de/path/file.txt"))
					== "https://example.com/index.html"
			)
		}

		@Test("Same path is irrelevant if scheme doesn't match")
		func samePathIsIrrelevantIfSchemeDoesntMatch() {
			#expect(
				URL("ftp://warez.ru/foo/bar/")
					.relativePath(resolvedAgainst: URL("http://warez.ru/foo/bar/")) == "ftp://warez.ru/foo/bar/"
			)
		}
	}

	@Suite("From root directory") struct RootBase {
		let base = URL(fileURLWithPath: "/")

		@Test func addingDirectory() {
			let path = URL(fileURLWithPath: "/dir/")
			#expect(path.relativePath(resolvedAgainst: base) == "dir")
		}

		@Test
		func addingFile() {
			let path = URL(fileURLWithPath: "/file")
			#expect(path.relativePath(resolvedAgainst: base) == "file")
		}

		@Suite("With file in root") struct WithFile {
			let base = URL(fileURLWithPath: "/irrelevant")
			@Test
			func withFileInRoot_AddingDirectory() {
				let path = URL(fileURLWithPath: "/dir/")
				#expect(path.relativePath(resolvedAgainst: base) == "dir")
			}

			@Test
			func withFileInRoot_AddingFile() {
				let path = URL(fileURLWithPath: "/file")
				#expect(path.relativePath(resolvedAgainst: base) == "file")
			}
		}
	}

	@Suite("Shared directory") struct SharedBaseDir {
		@Test("is fully contained (both are equal)")
		func samePaths() {
			let base = URL(fileURLWithPath: "/base/path/")
			let path = URL(fileURLWithPath: "/base/path/")
			#expect(path.relativePath(resolvedAgainst: base) == ".")
		}

		@Test("is followed by another directory")
		func addingDirectory() {
			let base = URL(fileURLWithPath: "/tmp/")
			let path = URL(fileURLWithPath: "/tmp/dir/")
			#expect(path.relativePath(resolvedAgainst: base) == "dir")
		}

		@Test("is followed by a file")
		func addingFile() {
			let base = URL(fileURLWithPath: "/tmp/")
			let path = URL(fileURLWithPath: "/tmp/file")
			#expect(path.relativePath(resolvedAgainst: base) == "file")
		}

		@Suite("with an additional file in the base URL") struct WithFileInBase {
			let base = URL(fileURLWithPath: "/tmp/irrelevant")
			@Test
			func addingDirectory() {
				let path = URL(fileURLWithPath: "/tmp/dir/")
				#expect(path.relativePath(resolvedAgainst: base) == "dir")
			}

			@Test
			func addingFile() {
				let path = URL(fileURLWithPath: "/tmp/file")
				#expect(path.relativePath(resolvedAgainst: base) == "file")
			}
		}

		@Suite("with an additional directory in the base URL") struct WithDirectoryInBase {
			let base = URL(fileURLWithPath: "/base/directory/")

			@Test
			func siblingToLastBaseDir() {
				let path = URL(fileURLWithPath: "/base/sibling/")
				#expect(path.relativePath(resolvedAgainst: base) == "../sibling")
			}

			@Test
			func siblingWithFileToLastBaseDir() {
				let path = URL(fileURLWithPath: "/base/sibling/file")
				#expect(path.relativePath(resolvedAgainst: base) == "../sibling/file")
			}

			@Suite("and a file") struct AndFile {
				let base = URL(fileURLWithPath: "/base/directory/irrelevant")
				@Test
				func siblingToLastBaseDir_WithFileInBaseDir() {
					let path = URL(fileURLWithPath: "/base/sibling/")
					#expect(path.relativePath(resolvedAgainst: base) == "../sibling")
				}

				@Test
				func siblingWithFileToLastBaseDir_WithFileInBaseDir() {
					let path = URL(fileURLWithPath: "/base/sibling/file")
					#expect(path.relativePath(resolvedAgainst: base) == "../sibling/file")
				}
			}

			@Test
			func ancestorOfBase() {
				let base = URL(fileURLWithPath: "/base/path/to/its/fullest/")
				let path = URL(fileURLWithPath: "/base/path/")
				#expect(path.relativePath(resolvedAgainst: base) == "../../..")
			}

			@Test
			func siblingToParentOfParentOfBaseDir() {
				let base = URL(fileURLWithPath: "/base/path/to/its/fullest/")
				let path = URL(fileURLWithPath: "/base/path/sibling/")
				#expect(path.relativePath(resolvedAgainst: base) == "../../../sibling")
			}
		}
	}

	@Test
	func nothingInCommon() {
		let base = URL(fileURLWithPath: "/base/path/")
		let path = URL(fileURLWithPath: "/absolute/path")
		#expect(path.relativePath(resolvedAgainst: base) == "/absolute/path")
	}

	@Test
	func relativePath() {
		let base = URL(fileURLWithPath: "/base/path/")
		let path = URL(fileURLWithPath: "../sibling/file", relativeTo: base)
		#expect(path.relativePath(resolvedAgainst: base) == "../sibling/file")
	}

	@Test
	func relativePathToBaseParent() {
		let base = URL(fileURLWithPath: "/base/parent/path/")
		let path = URL(fileURLWithPath: "../sibling/file", relativeTo: URL(fileURLWithPath: "/base/parent/"))
		#expect(path.relativePath(resolvedAgainst: base) == "../../sibling/file")
	}
}
