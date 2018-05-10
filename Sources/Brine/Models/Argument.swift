import XCTest
import Gherkin

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

    init?(match: Regex.Match, as type: MatchTransformable.Type, name: String? = nil) {
        guard type.patterns.contains(where: { match.text.any($0) }) else {
            return nil
        }
        self.match = match
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
        self.name = name
    }

    init?(_ table: GHDataTable) {
        let data: Data?
        if table.rows.first?.cells.count == 1 {
            let list = table.rows.flatMap { $0.cells.map { $0.value ?? "" } }
            data = try? JSONSerialization.data(withJSONObject: list)
        } else if let headers = table.rows.first {
            let table = Array(table.rows.dropFirst()).toTable(headers: headers)
            data = try? JSONSerialization.data(withJSONObject: table)
        } else {
            data = nil
        }
        guard let unwrappedData = data else {
            return nil
        }
        self.init(data: unwrappedData)
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

public struct StringArgument: Argument, CustomStringConvertible {
    public let name: String? = nil
    private let gherkin: GHDocString

    public var description: String {
        return gherkin.content
    }
    public var content: String {
        return description
    }
    public var contentType: String? {
        return gherkin.contentType
    }

    init(_ docString: GHDocString) {
        gherkin = docString
    }
}

public extension Array where Element: Argument {
    public func named(_ name: String) -> Argument? {
        return self.first { $0.name == name }
    }
}
