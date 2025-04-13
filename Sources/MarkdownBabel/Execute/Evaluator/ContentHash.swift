import Crypto

import struct Foundation.Data

struct ContentHash {
	let content: Data

	init(content: Data) {
		self.content = content
	}

	init?(string: String, encoding: String.Encoding = .utf8) {
		guard let data = string.data(using: encoding)
		else { return nil }
		self.init(content: data)
	}

	func contentHash() -> String {
		let digest = SHA256.hash(data: content)
		return
			digest
			.map { String(format: "%02x", $0) }
			.joined()
	}

	func callAsFunction() -> String {
		return contentHash()
	}
}
