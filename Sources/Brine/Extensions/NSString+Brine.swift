import Foundation

extension NSString {
    private static var invalidCharacters: CharacterSet = {
        let invalidCharacterSets: [CharacterSet] = [
            .whitespacesAndNewlines,
            .illegalCharacters,
            .controlCharacters,
            .punctuationCharacters,
            .nonBaseCharacters,
            .symbols
        ]
        return invalidCharacterSets.reduce(into: CharacterSet()) { $0.formUnion($1) }
    }()

    @objc(c99ExtendedIdentifier)
    var c99ExtendedIdentifier: String {
        let validComponents = components(separatedBy: NSString.invalidCharacters)
        let result = validComponents.joined(separator: "_")
        return result.isEmpty ? "_" : result
    }

    @objc(titlecasedString)
    public var titlecased: String {
        let capitalizedString = capitalized
        return capitalizedString.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
    }
}
