// 
//  Location.swift
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

import Gherkin

public struct Location: CustomStringConvertible {
    private let gherkin: GHLocation
    public let filePath: URL

    public var line: Int {
        return Int(gherkin.line)
    }

    public var column: Int {
        return Int(gherkin.column)
    }

    public var description: String {
        return "\(filePath.lastPathComponent) +\(line):\(column)"
    }

    init(from gherkin: GHLocation, filePath: URL) {
        self.gherkin = gherkin
        self.filePath = filePath
    }
}