enum SourceLocationParsingError: Error, Equatable, CustomStringConvertible {
	case notANumber(String)
	case notAPositiveNonZeroNumber(String, Int)

	var description: String {
		return switch self {
		case .notANumber(let input): "“\(input)” is not a number"
		case .notAPositiveNonZeroNumber(let str, let num): "\(num) needs to be 1 or larger (parsed from “\(str)”)"
		}
	}
}

func positiveNonZero(_ string: String) throws(SourceLocationParsingError) -> Int {
	guard let number = Int(string) else { throw .notANumber(string) }
	guard number > 0 else { throw .notAPositiveNonZeroNumber(string, number) }
	return number
}
