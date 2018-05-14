// 
//  Feature.swift
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
import ObjectiveC

@objcMembers
public class Feature: NSObject {
    public let scenarios: [Scenario]
    public weak var background: Scenario?
    public let tags: [Tag]
    let testClass: AnyClass?
    let location: Location
    private let gherkin: GHFeature

    init(from feature: GHFeature, filePath: URL, testClass: AnyClass? = nil) {
        gherkin = feature
        self.testClass = testClass
        location = Location(from: feature.location, filePath: filePath)
        tags = feature.tags.map(Tag.init)
        scenarios = feature.children.map { Scenario(from: $0, filePath: filePath) }
        super.init()
        scenarios.forEach { $0.parentTagsProvider = self }
    }
}

extension Feature: ParentTagsProvider {
    var parentTags: [Tag] {
        return tags
    }
}
