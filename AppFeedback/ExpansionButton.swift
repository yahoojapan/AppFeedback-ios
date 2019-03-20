//
//  ExpansionButton.swift
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
