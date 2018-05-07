public protocol Transformable {
    static func transform(_ string: String) -> Self?
}

public protocol MatchTransformable: Transformable {
    static var patterns: [String] { get }
    static func transform(_ match: Regex.Match) -> Self?
}

public protocol TableTransformable: Transformable {
    static func transform(_ table: [String: String]) -> Self?
}

extension String: Transformable {
    public static func transform(_ string: String) -> String? {
        return string
    }
}

extension Array where Element == String {
    func transform<T: Transformable>(into type: T.Type) -> [T] {
        return map { type.transform($0)! }
    }
}

extension Array where Element == [String: String] {
    func transform<T: TableTransformable>(into type: T.Type) -> [T] {
        return map { type.transform($0)! }
    }
}
