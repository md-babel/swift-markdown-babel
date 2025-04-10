import Foundation

let xdgConfigURL = FileManager.default.homeDirectoryForCurrentUser
	.appending(path: ".config", directoryHint: .isDirectory)
	.appending(path: "md-babel", directoryHint: .isDirectory)
	.appending(path: "config", directoryHint: .notDirectory)
	.appendingPathExtension("json")
