struct Not: Expression, CustomStringConvertible {
    let expr: Expression
    
    var description: String {
        return "not ( \(expr) )"
    }
    
    func evaluate(_ variables: [String]) -> Bool {
        return !expr.evaluate(variables)
    }
}
