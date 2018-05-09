import Foundation

struct Literal: Expression, CustomStringConvertible {
    let value: String
    
    var description: String {
        return value.replacingOccurrences(of: "\\(", with: "\\\\(")
            .replacingOccurrences(of: "\\)", with: "\\\\)")
    }
    
    func evaluate(_ variables: [String]) -> Bool {
        return variables.contains(value)
    }
}
