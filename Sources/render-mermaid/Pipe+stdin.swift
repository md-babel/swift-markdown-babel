import Foundation

extension Pipe {
	static func stdin(string: String) throws -> Pipe {
		let stdin = Pipe()
		let data = try string.data()
		stdin.fileHandleForWriting.writeabilityHandler = { handle in
			handle.write(data)
			try? handle.close()
			handle.writeabilityHandler = nil
		}
		return stdin
	}
}
