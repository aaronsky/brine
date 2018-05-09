import Foundation

private let escapingCharacter: Character = "\\"

public class TagExpressionParser {
    public init() {}
    
    public func parse(_ infix: String) throws -> Expression {
        let tokens = TagExpressionParser.tokenize(infix)
        guard !tokens.isEmpty else {
            return True()
        }
        
        var operators: [String] = []
        var expressions: [Expression] = []
        var expectedTokenType: TokenType = .operand
        
        for token in tokens {
            if token.isUnary {
                try check(expected: expectedTokenType, actual: .operand)
                operators.append(token)
                expectedTokenType = .operand
            } else if token.isBinary {
                try check(expected: expectedTokenType, actual: .operator)
                while let op = operators.first,
                    let tokenPrecedence = precedence(for: token),
                    let operatorPrecedence = precedence(for: op),
                    operators.count > 0 && op.isOperator &&
                        ((Assoc.associativeOperator(for: token) == .left &&
                            tokenPrecedence <= operatorPrecedence) ||
                            (Assoc.associativeOperator(for: token) == .right && tokenPrecedence < operatorPrecedence)) {
                                let expr = try pop(&operators)
                                try pushExpression(expr, onto: &expressions)
                }
                operators.append(token)
                expectedTokenType = .operand
            } else if token == "(" {
                try check(expected: expectedTokenType, actual: .operand)
                operators.append(token)
                expectedTokenType = .operand
            } else if token == ")" {
                try check(expected: expectedTokenType, actual: .operator)
                while operators.count > 0 && operators.first != "(" {
                    let op = try pop(&operators)
                    try pushExpression(op, onto: &expressions)
                }
                if operators.isEmpty {
                    throw TagExpressionParserError.unexpectedCloseParens
                } else if operators.first == "(" {
                    try pop(&operators)
                }
                expectedTokenType = .operator
            } else {
                try check(expected: expectedTokenType, actual: .operand)
                try pushExpression(token, onto: &expressions)
                expectedTokenType = .operator
            }
        }
        
        while operators.count > 0 {
            guard operators.first != "(" else {
                throw TagExpressionParserError.unexpectedOpenParens
            }
            let `operator` = try pop(&operators)
            try pushExpression(`operator`, onto: &expressions)
        }
        return expressions.removeFirst()
    }
    
    private class func tokenize(_ expression: String) -> [String] {
        var tokens: [String] = []
        var isEscaped = false
        var token: String? = nil
        for character in expression {
            guard character != escapingCharacter else {
                isEscaped = true
                continue
            }
            if token != nil && character.unicodeScalars.contains(where: { CharacterSet.whitespacesAndNewlines.contains($0) }) {
                tokens.append(token!)
                token = nil
                continue
            }
            switch character {
            case "(", ")":
                guard !isEscaped else {
                    fallthrough
                }
                if token != nil {
                    tokens.append(token!)
                    token = nil
                }
                tokens.append(String(character))
            default:
                if token == nil {
                    token = ""
                }
                token?.append(character)
            }
        }
        if let token = token {
            tokens.append(token)
        }
        return tokens
    }
    
    private func check(expected: TokenType, actual: TokenType) throws {
        guard expected == actual else {
            throw TagExpressionParserError.unexpectedToken(expected.description)
        }
    }
    
    private func pushExpression(_ token: String, onto queue: inout [Expression]) throws {
        switch token {
        case "and":
            let rightAndExpr = try pop(&queue)
            let leftAndExpr = try pop(&queue)
            queue.append(And(left: leftAndExpr, right: rightAndExpr))
        case "or":
            let rightOrExpr = try pop(&queue)
            let leftOrExpr = try pop(&queue)
            queue.append(Or(left: leftOrExpr, right: rightOrExpr))
        case "not":
            let notExpr = try pop(&queue)
            queue.append(Not(expr: notExpr))
        default:
            queue.append(Literal(value: token))
        }
    }
    
    @discardableResult private func pop<T>(_ queue: inout [T]) throws -> T {
        guard !queue.isEmpty else {
            throw TagExpressionParserError.emptyQueue
        }
        return queue.removeFirst()
    }
}

public enum TagExpressionParserError: Error {
    case unexpectedOpenParens
    case unexpectedCloseParens
    case unexpectedToken(String)
    case emptyQueue
}

private enum TokenType: CustomStringConvertible {
    case operand
    case `operator`
    
    var description: String {
        switch self {
        case .operand: return "operand"
        case .operator: return "operator"
        }
    }
}

private enum Assoc {
    case left
    case right
    
    static func associativeOperator(for string: String) -> Assoc? {
        switch string {
        case "or", "and": return .left
        case "not": return .right
        default: return nil
        }
    }
}

extension String {
    var isUnary: Bool {
        return self == "not"
    }
    
    var isBinary: Bool {
        return self == "or" || self == "and"
    }
    
    var isOperator: Bool {
        return Assoc.associativeOperator(for: self) != nil
    }
}

private func precedence(for string: String) -> Int? {
    switch string {
    case "(": return -2
    case ")": return -1
    case "or": return 0
    case "and": return 1
    case "not": return 2
    default: return nil
    }
}
