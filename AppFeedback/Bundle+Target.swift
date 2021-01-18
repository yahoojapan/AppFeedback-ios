//
//  Bundle+Target.swift
//  AppFeedback
//
//  Created by 大前 久基 on 2021/01/18.
//  Copyright © 2021 Yahoo! JAPAN Corporation. All rights reserved.
//

import Foundation

extension Bundle {
    static var target: Bundle? {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(identifier: "jp.co.yahoo.AppFeedback")
        #endif
    }
}
