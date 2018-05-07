public protocol Argument {
    var name: String? { get }
}

public struct MatchArgument: Argument {
    let match: Regex.Match
    let type: MatchTransformable.Type
    public let name: String?

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

public struct ListArgument: Argument {
    let list: [String]
    public let name: String?

    init(list: [String], name: String? = nil) {
        self.list = list
        self.name = nil
    }

    public func get<T: Transformable>(asListOf type: T.Type) -> [T] {
        return list.transform(into: T.self)
    }
}

public struct TableArgument: Argument {
    let table: [[String: String]]
    public let name: String?

    init(table: [[String: String]], name: String? = nil) {
        self.table = table
        self.name = nil
    }

    public func get<T: TableTransformable>(asTableOf type: T.Type) -> [T] {
        return table.transform(into: T.self)
    }
}

public extension Array where Element == Argument {
    public subscript(_ name: String) -> Argument? {
        return self.first { $0.name == name }
    }
}
