//
//  ExpansionButton.swift
//  AppFeedback
//
//  Created by 鎌倉 和弘 on 2019/03/15.
//  Copyright © 2019 Yahoo! JAPAN Corporation. All rights reserved.
//

import UIKit

private var leftPerceivableArea: CGFloat = 0.0
private var rightPerceivableArea: CGFloat = 0.0

@objcMembers
public class ExpansionButton: UIButton {
    public func setPerceivableArea(leftArea: CGFloat, rightArea: CGFloat) {
        leftPerceivableArea = leftArea
        rightPerceivableArea = rightArea
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // タップ確認用の CGRect を新規作成
        var rect: CGRect = bounds
        
        // 指定した Area 分、拡張する（位置をオフセットし、幅を足す）
        rect.origin.x -= leftPerceivableArea
        rect.size.width += leftPerceivableArea + rightPerceivableArea
        
        // 拡張したエリアとのタップ判定を返す
        return rect.contains(point)
    }
}
