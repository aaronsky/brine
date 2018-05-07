import Brine

extension Int: MatchTransformable {
    public static var patterns: [String] = ["(-?\\d+)"]

    public static func transform(_ string: String) -> Int? {
        return Int(string)
    }

    public static func transform(_ match: Regex.Match) -> Int? {
        guard let first = match[0]?.match else {
            return nil
        }
        return Int(first)
    }
}

public struct User: TableTransformable {
    let name: String
    let password: String

    init?(name: String?, password: String?) {
        guard let name = name, let password = password else {
            return nil
        }
        self.name = name
        self.password = password
    }

    public static func transform(_ string: String) -> User? {
        return nil
    }

    public static func transform(_ table: [String: String]) -> User? {
        return User(name: table["name"], password: table["password"])
    }
}
