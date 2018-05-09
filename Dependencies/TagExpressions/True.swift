struct True: Expression {
    func evaluate(_ variables: [String]) -> Bool {
        return true
    }
}
