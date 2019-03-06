//
//  SendData.swift
//  AppFeedback
//
//  Created by Shota Nakagami on 2019/03/06.
//  Copyright © 2019 Yahoo! JAPAN Corporation. All rights reserved.
//

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
