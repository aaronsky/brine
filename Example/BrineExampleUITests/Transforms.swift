import Brine

extension Int: MatchTransformable {
    public static var patterns: [String] = ["(-?\\d+)"]

    public static func transform(_ string: String) -> Int? {
        return Int(string)
    }

    public static func transform(_ match: Regex.Match) -> Int? {
        guard let str = match[0]?.match else {
            return nil
        }
        return Int(str)
    }
}

struct User: Codable {
    let name: String
    let password: String
}
