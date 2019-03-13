//
//  OverlayWindow.swift
//  OverlayWindow
//
//  Copyright (c) 2019 Yahoo Japan Corporation.
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

@objcMembers
public final class OverlayWindow: UIWindow {
    // TODO: move to FloatingButton.swift
    public static let floatingButtonWindowLevel = CGFloat.greatestFiniteMagnitude - 1000
    public static let overlayWindowLevel = floatingButtonWindowLevel - 1000

    override init(frame: CGRect) {
        super.init(frame: frame)
        windowLevel = .init(OverlayWindow.overlayWindowLevel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // FIXME:
            self.backgroundColor = nil
            self.layer.backgroundColor = nil
        }

        rootViewController = UIViewController()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func present(_ viewControllerToPreesnt: UIViewController,
                        animated: Bool,
                        completion: (() -> Void)? = nil) {
        isHidden = false
        rootViewController?.present(
            viewControllerToPreesnt,
            animated: animated) {
                Timer.scheduledTimer(timeInterval: 0.2,
                                     target: self,
                                     selector: #selector(self.monitorModal),
                                     userInfo: nil,
                                     repeats: true)
                completion?()
        }
    }

    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return rootViewController?.presentedViewController != nil
    }

    @objc private func monitorModal(_ timer: Timer) {
        if rootViewController?.presentedViewController == nil {
            timer.invalidate()
            isHidden = true
        }
    }
}
