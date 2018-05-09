public protocol Expression {
    func evaluate(_ variables: [String]) -> Bool
}
