//
//  SendData.swift
//  AppFeedback
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

import Foundation

@objcMembers
public class SendData: NSObject {
    // TODO: Remove Optional
    public let imageData: Data?
    public let videoPath: URL?
    public let title: String?
    public let category: String?
    public let comment: String?
    public let username: String?
    public let appTitle: String?
    public let appVersion: String?
    public let appBuildVersion: String?
    public let systemVersion: String?
    public let modelCode: String?
    public let modelName: String?
    
    public init(imageData: Data?,
                videoPath: URL?,
                title: String?,
                category: String?,
                comment: String?,
                username: String?,
                appTitle: String?,
                appVersion: String?,
                appBuildVersion: String?,
                systemVersion: String?,
                modelCode: String?,
                modelName: String?) {
        self.imageData = imageData
        self.videoPath = videoPath
        self.title = title
        self.category = category
        self.comment = comment
        self.username = username
        self.appTitle = appTitle
        self.appVersion = appVersion
        self.appBuildVersion = appBuildVersion
        self.systemVersion = systemVersion
        self.modelCode = modelCode
        self.modelName = modelName
    }
}
