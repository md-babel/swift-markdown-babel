enum Either<Left, Right> {
	case left(Left)
	case right(Right)
}

extension Either: Sendable where Left: Sendable, Right: Sendable {}

extension Either: Equatable where Left: Equatable, Right: Equatable {
	static func == (lhs: Self, rhs: Self) -> Bool {
		return switch (lhs, rhs) {
		case (.left(let lValue), .left(let rValue)): lValue == rValue
		case (.right(let lValue), .right(let rValue)): lValue == rValue
		case (.left, .right),
			(.right, .left):
			false
		}
	}
}
