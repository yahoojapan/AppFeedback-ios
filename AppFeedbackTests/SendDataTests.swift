//
//  SendDataTests.swift
//  AppFeedbackTests
//
//  Created by Shota Nakagami on 2019/03/20.
//  Copyright © 2019 Yahoo! JAPAN Corporation. All rights reserved.
//

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
