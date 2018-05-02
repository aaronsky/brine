import Foundation

public extension NSString {

    private static var invalidCharacters: CharacterSet = {
        var invalidCharacters = CharacterSet()

        let invalidCharacterSets: [CharacterSet] = [
            .whitespacesAndNewlines,
            .illegalCharacters,
            .controlCharacters,
            .punctuationCharacters,
            .nonBaseCharacters,
            .symbols
        ]

        for invalidSet in invalidCharacterSets {
            invalidCharacters.formUnion(invalidSet)
        }

        return invalidCharacters
    }()

    @objc(brine_c99ExtendedIdentifier)
    var c99ExtendedIdentifier: String {
        let validComponents = components(separatedBy: NSString.invalidCharacters)
        let result = validComponents.joined(separator: "_")

        return result.isEmpty ? "_" : result
    }
}
