import struct Foundation.URL

extension Array where Element: Equatable {
	fileprivate func commonPrefix(_ other: [Element]) -> [Element] {
		var result: [Element] = []
		for (lhs, rhs) in zip(self, other) {
			guard lhs == rhs else {
				break
			}
			result.append(lhs)
		}
		return result
	}
}

extension URL {
	/// Produces a relative path to get from `baseURL` to the receiver for use in e.g. labels.
	///
	/// When there's no common ancestor, e.g. `/tmp/` and `/var/`, then this returns an absolute path. The only exception to this rule is when `baseURL` itself is the root `/`, since tor that base _all_ paths are relative.
	///
	/// - Returns: Shortest relative path to get from `baseURL` to receiver, e.g. `"../../subdirectory/file.txt"`, and `"."` if both are identical. Absolute path (or absolute URL for non-`file://` URLs) if there's nothing in common.
	package func relativePath(resolvedAgainst baseURL: URL) -> String {
		guard let url = self.relativeURL(resolvedAgainst: baseURL) else {
			if self.isFileURL {
				// Produce absolute file path
				return self.path
			} else if self.scheme == baseURL.scheme && self.host == baseURL.host {
				// For e.g. web URLs, if protocol and domain are the same, drop the shared part and return only the absolute path.
				return self.path
			} else {
				// If everything differs in non-file URLs, produce the whole URL string.
				return self.absoluteString
			}
		}

		let path = url.relativePath
		guard path.hasPrefix("./") else {
			return path
		}
		// Avoid "./file.txt" and "./../sibling/path.txt" by dropping the current dir part.
		return String(path.dropFirst(2))
	}

	/// - Returns: `nil` if the URLs cannot be compared (e.g. file vs http scheme) or have nothing in common.
	private func relativeURL(resolvedAgainst baseURL: URL) -> URL? {
		// Protect against cross-domain or cross-scheme URL comparison attempts.
		guard self.scheme == baseURL.scheme,
			self.host == baseURL.host
		else {
			return nil
		}

		// Ignore file in base directory path.
		guard baseURL.hasDirectoryPath else {
			return self.relativeURL(resolvedAgainst: baseURL.deletingLastPathComponent())
		}

		// Ignore the file when comparing the reference URL (self) to baseURL, but do preserve the file for a full path.
		guard self.hasDirectoryPath else {
			// Append target file name to result to get not just the path directions, but the total result. The use of an array and filter gets rid of empty `resolvedDirectoryPath` strings in one go, i.e when the base directory and the current directory are one and the same.
			return self.deletingLastPathComponent()
				.relativeURL(resolvedAgainst: baseURL)?
				.appendingPathComponent(self.lastPathComponent)
		}

		// We can rely on `pathComponents` producing absolute paths: even when using the relative URL initializer, `pathComponents` are resolved using the implicit base URL during initialization (for Xcode tests, that's the derived data path, and in the Swift REPL the working directory of the shell).
		let sharedPathComponents = self.pathComponents.commonPrefix(baseURL.pathComponents)

		// No path component in common with `baseURL`. (Except when base is root.)
		if sharedPathComponents == ["/"]
			&& baseURL.pathComponents != ["/"]
		{
			return nil
		}

		let uniqueBasePathComponents = baseURL.pathComponents.dropFirst(sharedPathComponents.count)
		let uniqueReferencePathComponents = self.pathComponents.dropFirst(sharedPathComponents.count)

		let goToParent = uniqueBasePathComponents.map { _ in ".." }
		let drillDownToPath = uniqueReferencePathComponents
		return (goToParent + drillDownToPath)
			.reduce(URL(fileURLWithPath: "", relativeTo: baseURL)) { $0.appendingPathComponent($1) }
	}
}
