// 
//  Argument.swift
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

import XCTest
import Gherkin

/// Protocol type for types that can provide step argument transformation
/// capabilities
public protocol MatchTransformable {
    /// List of patterns that should be associated with this transform
    static var patterns: [String] { get }
    /// Given a match, transform the `String` match into this type.
    /// Should return `nil` if the transform should fail.
    static func transform(_ match: Regex.Match) -> Self?
}

/// Base interface type for arguments
public protocol Argument {
    /// Name of the argument
    var name: String? { get }
}

/// Argument type to hold `MatchTransformable` content. Currently
/// intended for use with Gherkin step argument transforms.
public struct MatchArgument: Argument {
    /// Name of the argument
    public let name: String?
    let match: Regex.Match

    init?(match: Regex.Match, as type: MatchTransformable.Type, name: String? = nil) {
        guard type.patterns.contains(where: { match.text.any($0) }) else {
            return nil
        }
        self.match = match
        self.name = nil
    }

    /// Attempts to transform the match using the given transform.
    /// If the transform fails, it will return `nil`.
    public func get<T: MatchTransformable>(as type: T.Type) -> T? {
        return type.transform(match)
    }
}

/// Argument type to hold `Codable` content. Currently intended
/// for use with Gherkin data tables and data lists (unkeyed tables)
public struct CodableArgument: Argument {
    /// Name of the argument
    public let name: String?
    let data: Data

    init(data: Data, name: String? = nil) {
        self.data = data
        self.name = name
    }

    init?(_ table: GHDataTable) {
        let data: Data?
        if table.rows.first?.cells.count == 1 {
            let list = table.rows.flatMap { $0.cells.map { $0.value ?? "" } }
            data = try? JSONSerialization.data(withJSONObject: list)
        } else if let headers = table.rows.first {
            let table = Array(table.rows.dropFirst()).toTable(headers: headers)
            data = try? JSONSerialization.data(withJSONObject: table)
        } else {
            data = nil
        }
        guard let unwrappedData = data else {
            return nil
        }
        self.init(data: unwrappedData)
    }

    /// Attempts to decode the data table as a `Decodable` type. This is a destructive method that
    /// will short-circuit if it fails to decode. Optionally will take a decoder with overridden
    /// decoding strategies.
    public func get<T: Decodable>(_ type: T.Type, using decoder: JSONDecoder = JSONDecoder()) -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            XCTFail(error.localizedDescription)
            fatalError("Something has gone very wrong if the test reaches this point")
        }
    }
}

/// Argument type to hold `String` content. Currently intended
/// only for use with Gherkin doc strings.
public struct StringArgument: Argument, CustomStringConvertible {
    /// Name of the argument
    public let name: String? = nil
    private let gherkin: GHDocString

    /// Swift-y convention to return `StringArgument.content`
    public var description: String {
        return content
    }

    /// Returns the content of the doc string
    public var content: String {
        return gherkin.content
    }

    /// Returns the content type of the doc string from Gherkin
    public var contentType: String? {
        return gherkin.contentType
    }

    init(_ docString: GHDocString) {
        gherkin = docString
    }
}

public extension Array where Element: Argument {
    /// If the `Array` is an `Array` of `Argument`s, this is a way
    /// to conveniently retrieve the argument by its `Argument.name`
    /// identifier.
    public func named(_ name: String) -> Argument? {
        return self.first { $0.name == name }
    }
}
