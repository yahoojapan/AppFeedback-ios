//
//  Config.swift
//  AppFeedback
//
//  Created by 堀泰祐 on 2020/11/29.
//  Copyright © 2020 Yahoo! JAPAN Corporation. All rights reserved.
//

import Foundation

@objcMembers
public class Config: NSObject {
    /// feedback カテゴリの一覧
    public var categories: [String]

    public var slackApiUrl: String
    public var slackToken: String = ""
    public var slackChannel: String = ""
    public var branchName: String?

    override init() {
        self.categories = [
            AppFeedbackLocalizedString.string(for: "bug"),
            AppFeedbackLocalizedString.string(for: "request"),
            AppFeedbackLocalizedString.string(for: "question"),
            AppFeedbackLocalizedString.string(for: "design"),
            AppFeedbackLocalizedString.string(for: "others")
        ]
        self.slackApiUrl = "https://slack.com/api"
    }

    /**
     アプリの Info.plist からSDK用の設定を読み込む
     */
    public func loadInfoPlist() {
        guard let info = Bundle.main.infoDictionary else { return }
        self.loadInfoPlistDic(info)
    }
    
    private func loadInfoPlistDic(_ info: [String: Any]) {
        // TODO: read branch information
        if let value = self.getRequiredKey(info, key:"AppFeedback_SlackApiToken") {
            self.slackToken = value
        }
        if let value = self.getRequiredKey(info, key:"AppFeedback_SlackChannel") {
            self.slackChannel = value
        }
        if let value = self.getRequiredKey(info, key:"AppFeedback_SlackApiUrl") {
            self.slackApiUrl = value
        }
        if let value = self.getRequiredKey(info, key:"AppFeedback_Branch") {
            self.branchName = value
        }
    }
    
    public func getRequiredKey(_ info: [String: Any], key: String) -> String? {
        guard let value = info[key] as? String else {
            NSLog("AppFeedback: %@ not found in Info.plist", key);
            return nil
        }
        return value
    }



    public var isValid: Bool {
        return !self.slackToken.isEmpty && !self.slackChannel.isEmpty
    }
}
