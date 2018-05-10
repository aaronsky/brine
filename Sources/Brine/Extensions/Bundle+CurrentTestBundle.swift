// 
//  Bundle+CurrentTestBundle.swift
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

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)

import Foundation

extension Bundle {

    /**
     Locates the first bundle with a '.xctest' file extension.
     */
    internal static var currentTestBundle: Bundle? {
        return allBundles.first { $0.bundlePath.hasSuffix(".xctest") }
    }

    /**
     Return the module name of the bundle.
     Uses the bundle filename and transform it to match Xcode's transformation.
     Module name has to be a valid "C99 extended identifier".
     */
    internal var moduleName: String {
        let fileName = bundleURL.fileName as NSString
        return fileName.c99ExtendedIdentifier
    }
}

#endif
