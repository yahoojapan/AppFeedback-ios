//
//  FloatingProgressView.swift
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

@objcMembers
public class FloatingProgressView: UIView {
    
    let LINE_WIDTH: CGFloat = 3.0
    var shapeLayer: CALayer?


    public func startProgress(Secs: Float) {
        startAnimation(Secs: Secs)
    }
    
    public func endProgress() {
        shapeLayer?.removeAllAnimations()
        shapeLayer?.removeFromSuperlayer()
        shapeLayer = nil
    }
    
    public func startAnimation(Secs: Float) {
        let shapeLayer = CAShapeLayer()
        
        let path: UIBezierPath? = makeCircle(atLocation: center, radius: frame.size.width / 2 - LINE_WIDTH / 2, percent: 1)
        shapeLayer.path = path?.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = LINE_WIDTH
        shapeLayer.backgroundColor = UIColor.blue.cgColor
        layer.addSublayer(shapeLayer)
        
        let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimation.duration = CFTimeInterval(Secs)
        pathAnimation.fromValue = NSNumber(value: 0.0)
        pathAnimation.toValue = NSNumber(value: 1.0)
        shapeLayer.add(pathAnimation, forKey: "drawCircleAnimation")
        
        self.shapeLayer = shapeLayer
    }
    
    func makeCircle(atLocation location: CGPoint, radius: CGFloat, percent: CGFloat) -> UIBezierPath? {
        let path = UIBezierPath()
        
        path.addArc(withCenter: location, radius: radius, startAngle: CGFloat(.pi + Double.pi/2), endAngle: CGFloat(.pi + Double.pi/2) + (.pi * 2.0) * percent, clockwise: true)
        
        path.lineWidth = LINE_WIDTH
        return path
    }



    
}
