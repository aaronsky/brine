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

    public var tags: [Tag] {
        return (parentTagsProvider?.parentTags ?? []) + exampleTags
    }

    public init(from example: GHExamples) {
        gherkin = example
        data = gherkin.tableBody.toTable(headers: example.tableHeader)
        exampleTags = gherkin.tags.map(Tag.init)
    }
}

extension Array where Element == GHTableRow {
    func toTable(headers: GHTableRow) -> [[String: String]] {
        return map { zip(headers.cells, $0.cells)
                .reduce(into: [String: String]()) { $0[$1.0.value] = $1.1.value }
        }
    }
}
