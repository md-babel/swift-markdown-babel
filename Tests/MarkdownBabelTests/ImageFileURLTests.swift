import MarkdownBabel
import Testing

import struct Foundation.URL

@Suite("ImageFileURL")
struct ImageFileURLTests {
	@Suite("path()") struct PathTests {
		@Test("absolute file URL without base dir")
		func pathWithAbsoluteURL() throws {
			let imageURL = ImageFileURL(
				fileURL: URL(filePath: "/Users/test/images/photo.jpg"),
				relativizigWorkingDirectory: nil
			)

			#expect(imageURL.path() == "/Users/test/images/photo.jpg")
		}

		@Suite("relative to base directory") struct Relativizing {
			let baseDir = URL(filePath: "/Users/test/")

			@Test("absolute file URL in base directory")
			func absoluteFileURL() throws {
				let imageURL = ImageFileURL(
					fileURL: URL(filePath: "/Users/test/images/photo.jpg"),
					relativizigWorkingDirectory: baseDir
				)

				#expect(imageURL.path() == "images/photo.jpg")
			}

			@Test("relative file URL in base directory")
			func relativeFileURL() throws {
				let imageURL = ImageFileURL(
					fileURL: URL(filePath: "images/photo.jpg", relativeTo: baseDir),
					relativizigWorkingDirectory: baseDir
				)

				#expect(imageURL.path() == "images/photo.jpg")
			}

			@Test("absolute file URL in sibling directory to base")
			func absoluteFileURLDifferentDirectory() throws {
				let imageURL = ImageFileURL(
					fileURL: URL(filePath: "/Users/peter/projects/app/images/photo.jpg"),
					relativizigWorkingDirectory: baseDir
				)

				#expect(imageURL.path() == "../peter/projects/app/images/photo.jpg")
			}

			@Test("relative file URL in sibling directory to base")
			func relativeFileURLDifferentDirectory() throws {
				let imageURL = ImageFileURL(
					fileURL: URL(filePath: "app/images/photo.jpg", relativeTo: URL(filePath: "/Users/peter/projects/")),
					relativizigWorkingDirectory: baseDir
				)

				#expect(imageURL.path() == "../peter/projects/app/images/photo.jpg")
			}
		}
	}
}
