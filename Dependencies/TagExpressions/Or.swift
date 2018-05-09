struct Or: Expression, CustomStringConvertible {
    let left: Expression
    let right: Expression
    
    var description: String {
        return "( \(left) or \(right) )"
    }
    
    func evaluate(_ variables: [String]) -> Bool {
        return left.evaluate(variables) || right.evaluate(variables)
    }
}
