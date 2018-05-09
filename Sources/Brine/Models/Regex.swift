import Foundation

public struct Regex {
    private let regularExpression: NSRegularExpression

    public var nsRegularExpression: NSRegularExpression {
        return regularExpression
    }

    public init(_ pattern: String, options: [Option] = []) {
        do {
            regularExpression = try NSRegularExpression(pattern: pattern, options: options.nsOptionSet)
        } catch {
            preconditionFailure("Error while creating regex: \(error)")
        }
    }

    public func matches(for string: String) -> [Match] {
        let matches = regularExpression.matches(in: string, range: NSRange(location: 0, length: string.count))
        return matches.compactMap { Match(nsMatch: $0, for: string) }
    }

    public func any(_ string: String) -> Bool {
        return regularExpression.numberOfMatches(in: string, range: NSRange(location: 0, length: string.count)) > 0
    }

    public enum Option {
        case ignoreCase
        case ignoreMetacharacters
        case anchorsMatchLines
        case dotMatchesLineSeparators
    }

    public typealias CaptureGroup = (match: String, index: Int)

    public struct Match {
        public let text: String
        private let captureGroups: [CaptureGroup]

        init?(nsMatch: NSTextCheckingResult, for string: String) {
            guard let range = Range(nsMatch.range, in: string) else {
                return nil
            }
            self.text = String(string[range])

            let lastCaptureIndex = nsMatch.numberOfRanges - 1
            guard lastCaptureIndex >= 1 else {
                self.captureGroups = []
                return
            }
            self.captureGroups = (1...lastCaptureIndex).compactMap { index in
                guard let captureGroupRange = Range(nsMatch.range(at: index), in: string) else {
                    return nil
                }
                return (match: String(string[captureGroupRange]), index: index)
            }
        }

        public subscript(index: Int) -> CaptureGroup? {
            guard index >= 0 && index < captureGroups.count else {
                return nil
            }
            return captureGroups[index]
        }
    }
}

extension Regex: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension Regex: CustomStringConvertible {
    public var description: String {
        return regularExpression.pattern
    }
}

extension Regex: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

extension String {
    func matches(_ pattern: String) -> [Regex.Match] {
        return matches(pattern: Regex(pattern))
    }

    func matches(pattern: Regex) -> [Regex.Match] {
        return pattern.matches(for: self)
    }

    func any(_ pattern: String) -> Bool {
        return any(pattern: Regex(pattern))
    }

    func any(pattern: Regex) -> Bool {
        return pattern.any(self)
    }
}

extension Array where Element == Regex.Option {
    var nsOptionSet: NSRegularExpression.Options {
        return NSRegularExpression.Options(self.map({
            switch $0 {
            case .ignoreCase: return .caseInsensitive
            case .ignoreMetacharacters: return .ignoreMetacharacters
            case .anchorsMatchLines: return .anchorsMatchLines
            case .dotMatchesLineSeparators: return .dotMatchesLineSeparators
            }
        }))
    }
}
