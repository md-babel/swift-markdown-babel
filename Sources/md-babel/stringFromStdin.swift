import Foundation

func stringFromStdin(encoding: String.Encoding = .utf8) throws -> String? {
	// FIXME: Will break for stdin >64KiB, use safer pipe reading. https://github.com/md-babel/swift-markdown-babel/issues/13
	guard let data = try FileHandle.standardInput.readToEnd() else { return nil }
	return String(data: data, encoding: encoding)
}
