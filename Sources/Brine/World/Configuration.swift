// 
//  Configuration.swift
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

public struct Configuration {
    public let featuresPath: URL?
    public let strict: Bool
    public let tags: [String]
    public let tagExpression: String?

    public init() {
        let url = Bundle.currentTestBundle?.resourceURL?.appendingPathComponent("Features")
        self.init(featuresPath: url)
    }

    public init(featuresPath: URL?, strict: Bool = false, tags: [String] = [], tagExpression: String? = nil) {
        self.featuresPath = featuresPath
        self.strict = strict
        self.tags = tags
        self.tagExpression = tagExpression
    }

    func combine(into configuration: Configuration) -> Configuration {
        return Configuration(featuresPath: featuresPath ?? configuration.featuresPath,
                             strict: strict || configuration.strict,
                             tags: tags + configuration.tags,
                             tagExpression: tagExpression ?? configuration.tagExpression)
    }
}
