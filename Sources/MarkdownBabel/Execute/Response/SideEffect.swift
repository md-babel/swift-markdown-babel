import Foundation

public enum SideEffect: Equatable, Sendable {
	case writeFile(Data, to: URL)
}
