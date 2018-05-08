import XCTest

public protocol MatchTransformable {
    static var patterns: [String] { get }
    static func transform(_ match: Regex.Match) -> Self?
}

public protocol Argument {
    var name: String? { get }
}

public struct MatchArgument: Argument {
    public let name: String?
    let match: Regex.Match
    let type: MatchTransformable.Type

    init?(match: Regex.Match, type: MatchTransformable.Type, name: String? = nil) {
        guard type.patterns.contains(where: { match.text.any($0) }) else {
            return nil
        }
        self.match = match
        self.type = type
        self.name = nil
    }

    public func get<T: MatchTransformable>(as type: T.Type) -> T? {
        return type.transform(match)
    }
}

public struct CodableArgument: Argument {
    public let name: String?
    let data: Data

    init(data: Data, name: String? = nil) {
        self.data = data
        self.name = nil
    }

    public func get<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            XCTFail(error.localizedDescription)
            fatalError("Something has gone very wrong if the test reaches this point")
        }
    }
}

public extension Array where Element == Argument {
    public func named(_ name: String) -> Argument? {
        return self.first { $0.name == name }
    }
}
