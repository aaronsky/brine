// 
//  PredefinedSteps.swift
// 
//  Copyright 2018 Aaron Sky
// 
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
// 
//      http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// 

import Foundation

extension String {
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

    var c99ExtendedIdentifier: String {
        let validComponents = components(separatedBy: String.invalidCharacters)
        let result = validComponents.joined(separator: "_")
        return result.isEmpty ? "_" : result
    }

    var pascalcased: String {
        let capitalizedString = capitalized
        return capitalizedString.replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
    }
}
