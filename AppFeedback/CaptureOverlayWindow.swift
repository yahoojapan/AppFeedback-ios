//
//  CaptureOverlayWindow.swift
//  AppFeedback
//
//  Created by Tatsuya Tanaka on 2019/04/03.
//  Copyright © 2019 Yahoo! JAPAN Corporation. All rights reserved.
//

import UIKit

/// Detect a tap position of the video capturing & show the animation
@objcMembers
public class CaptureOverlayWindow: UIWindow {
    public var isCaptureEnabled = false {
        didSet {
            isHidden = !isCaptureEnabled
        }
    }

    public var floatingButtonWindow: UIWindow?

    override init(frame: CGRect) {
        super.init(frame: frame)
        windowLevel = .init(OverlayWindow.overlayWindowLevel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // FIXME:
            self.backgroundColor = nil
            self.layer.backgroundColor = nil
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func showAnimation(at point: CGPoint) {
        let radius: CGFloat = 12
        let fillColor = UIColor(red: 238 / 255, green: 1, blue: 1, alpha: 1)
        let borderColor = UIColor(red: 204 / 255, green: 204 / 255, blue: 204 / 255, alpha: 1)
        let duration = 0.5

        let animView = UIView(frame: .init(x: point.x - radius,
                                           y: point.y - radius,
                                           width: radius * 2,
                                           height: radius * 2))
        animView.layer.cornerRadius = radius
        animView.backgroundColor = fillColor
        animView.layer.borderColor = borderColor.cgColor
        animView.layer.borderWidth = 2

        rootViewController?.view.addSubview(animView)

        animView.alpha = 1
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
                        animView.alpha = 0
        }, completion: { finished in
            if finished {
                animView.removeFromSuperview()
            }
        })
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if !isUnderFloatingButton(point: point, with: event) {
            showAnimation(at: point)
        }
        return false
    }

    private func isUnderFloatingButton(point: CGPoint, with event: UIEvent?) -> Bool {
        guard let window = floatingButtonWindow else { return false }
        let buttonPoint = convert(point, to: window)
        return window.point(inside: buttonPoint, with: event)
    }
}
