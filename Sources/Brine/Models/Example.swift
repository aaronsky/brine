// 
//  Example.swift
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
import Gherkin

@objcMembers
public class Example: NSObject {
    public let data: [[String: String]]
    private let exampleTags: [Tag]
    private let gherkin: GHExamples
    weak var parentTagsProvider: ParentTagsProvider?

    public override var description: String {
        return gherkin.desc
    }

    var tags: [Tag] {
        return (parentTagsProvider?.parentTags ?? []) + exampleTags
    }

    init(from example: GHExamples) {
        gherkin = example
        data = Array(rows: gherkin.tableBody, headers: example.tableHeader)
        exampleTags = gherkin.tags.map(Tag.init)
    }
}

extension Array where Element == [String: String] {
    init(rows: [GHTableRow], headers: GHTableRow) {
        self = rows.map { row in
            zip(headers.cells, row.cells)
                .reduce(into: Element()) { $0[$1.0.value] = $1.1.value }
        }
    }
}
