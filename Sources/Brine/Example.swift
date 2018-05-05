//
//  Example.swift
//  Brine
//
//  Created by Aaron Sky on 5/4/18.
//

import Foundation
import Gherkin

@objcMembers
public class Example: NSObject {
    private let gherkin: GHExamples
    public let data: [[String: String]]

    public override var description: String {
        return gherkin.desc
    }

    public init(from example: GHExamples) {
        gherkin = example
        data = gherkin.tableBody.map { row in
            return zip(row.cells, example.tableHeader.cells)
                .reduce(into: [String: String]()) { accumulator, zip in
                accumulator[zip.0.value] = zip.1.value
            }
        }
    }
}
