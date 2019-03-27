//
//  UIColor+.swift
//  AppFeedback
//
//  Created by Shota Nakagami on 2019/03/27.
//  Copyright © 2019 Yahoo! JAPAN Corporation. All rights reserved.
//

import UIKit

extension UIColor {
    func RGBA(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
        return UIColor.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a / 255.0)
    }
}
