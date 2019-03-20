//
//  AppFeedbackLocalizedString.swift
//  AppFeedback
//
//  Created by Shota Nakagami on 2019/03/20.
//  Copyright © 2019 Yahoo! JAPAN Corporation. All rights reserved.
//

import Foundation

@objcMembers
public class AppFeedbackLocalizedString: NSObject {
    public static func string(for key: String) -> String {
        let frameWorkBundle = Bundle(for: AppFeedbackLocalizedString.self)
        return frameWorkBundle.localizedString(forKey: key, value: "", table: nil)
    }
}

