public enum Either<Left, Right> {
	case left(Left)
	case right(Right)
}

extension Either: Codable where Left: Codable, Right: Codable {
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()

		if let leftValue = try? container.decode(Left.self) {
			self = .left(leftValue)
		} else if let rightValue = try? container.decode(Right.self) {
			self = .right(rightValue)
		} else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Cannot decode either \(Left.self) or \(Right.self)"
			)
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()

		switch self {
		case .left(let value):
			try container.encode(value)
		case .right(let value):
			try container.encode(value)
		}
	}
}

extension Either: Sendable where Left: Sendable, Right: Sendable {}

extension Either: Equatable where Left: Equatable, Right: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		return switch (lhs, rhs) {
		case (.left(let lValue), .left(let rValue)): lValue == rValue
		case (.right(let lValue), .right(let rValue)): lValue == rValue
		case (.left, .right),
			(.right, .left):
			false
		}
	}
}
