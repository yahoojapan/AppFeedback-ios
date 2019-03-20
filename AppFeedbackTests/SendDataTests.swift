//
//  SendDataTests.swift
//  AppFeedbackTests
//
//  Copyright (c) 2018 Yahoo Japan Corporation.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import XCTest
@testable import AppFeedback

class SendDataTests: XCTestCase {
    func test_convertToMessage_withBranchName() {
        let data = SendData(imageData: nil,
                            videoPath: nil,
                            title: "title",
                            category: "category",
                            comment: "comment",
                            username: "username",
                            appTitle: "SampleApp",
                            appVersion: "1.0",
                            appBuildVersion: "1",
                            systemVersion: "12.1",
                            modelCode: "x86_64",
                            modelName: "Simulator")
        
        let expected = """
title
by @username

```
[Category]
category

[Message]
comment

[App Title]
SampleApp

[App Version]
Version: 1.0
Build: 1

[Device]
iOS: 12.1
Model: Simulator (x86_64)

[Branch]
branch
```
"""
        XCTAssertEqual(data.convertToMessage(with: "branch"), expected)
    }
    
    func test_convertToMessage_withoutBranchName() {
        let data = SendData(imageData: nil,
                            videoPath: nil,
                            title: "title",
                            category: "category",
                            comment: "comment",
                            username: "username",
                            appTitle: "SampleApp",
                            appVersion: "1.0",
                            appBuildVersion: "1",
                            systemVersion: "12.1",
                            modelCode: "x86_64",
                            modelName: "Simulator")
        
        let expected = """
title
by @username

```
[Category]
category

[Message]
comment

[App Title]
SampleApp

[App Version]
Version: 1.0
Build: 1

[Device]
iOS: 12.1
Model: Simulator (x86_64)
```
"""
        XCTAssertEqual(data.convertToMessage(with: nil), expected)
    }
}
