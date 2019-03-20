//
//  DrawView.swift
//  DrawView
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

import Foundation
import UIKit

@objc public protocol DrawViewDelegate: class {
    @objc func finishPannig(image: UIImage)
}

@objc public class DrawView: UIView {
    @objc public weak var delegate: DrawViewDelegate?
    
    // DrawViewに対する合成画像の大きさ
    let COMPOSITE_IMAGE_SIZE_RATIO: CGFloat = 2.0
    
    private weak var imageView: UIImageView?
    private var panningStartPoint: CGPoint = CGPoint.zero
    private var panningRect: CGRect = CGRect.zero
    private var lineWidthRatio: CGFloat = 0.0
    
    @objc public func linkUI(imageView: UIImageView) {
        self.imageView = imageView;        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let screen: CGRect = UIScreen.main.bounds

        // スクリーンサイズに対する強調枠線の太さの比を設定（4pxを基準とする）
        if (screen.size.width < screen.size.height) {
            self.lineWidthRatio = 4.0 / screen.size.width
        } else {
            self.lineWidthRatio = 4.0 / screen.size.height
        }
    }
    
    override public func draw(_ rect: CGRect) {
        // コンテキストの初期化
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setStrokeColor(UIColor.red.cgColor)
        // 強調枠線の太さを設定
        var lineWidth: CGFloat
    
        // Viewの縦・横幅の小さい方を基準として太さを決める
        if (self.frame.size.width < self.frame.size.height) {
            lineWidth = self.frame.size.width * self.lineWidthRatio;
        } else {
            lineWidth = self.frame.size.height * self.lineWidthRatio;
        }

        context.setLineWidth(lineWidth)
    
        // 強調枠線の描画
        context.addRect(self.panningRect)
        context.strokePath()
    }
    
    // UIViewの描画内容をUIImageに変換する
    func transformViewToImage() -> UIImage? {
        // コンテキストにUIViewの内容を描画
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        self.layer.render(in: context)

        // コンテキストの内容をUIImageに変換
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
    
        // コンテキストの解放
        UIGraphicsEndImageContext()
    
        return image
    }

    //画面がタッチされた時，描画開始座標を取得
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.panningStartPoint = touch.location(in: self)
    }
    
    // ドラッグ中の強調枠線を描画
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let panningCurrentPoint = touch.location(in: self)
        let panSize = CGSize(width: panningCurrentPoint.x - self.panningStartPoint.x, height: panningCurrentPoint.y - self.panningStartPoint.y)
        self.panningRect = CGRect(x: self.panningStartPoint.x, y: self.panningStartPoint.y, width: panSize.width, height: panSize.height)
        self.setNeedsDisplay()
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 合成素材(スクリーンショットのImage・強調枠線のImage)の初期化
        guard let drawImage = self.transformViewToImage() else { return }
        guard let origImage = self.imageView?.image?.cgImage else { return }
        let resizedOriginalImage = UIImage(cgImage: origImage)
    
        // 画像の合成
        let imageWidth = self.frame.size.width * COMPOSITE_IMAGE_SIZE_RATIO
        let imageHeight = self.frame.size.height * COMPOSITE_IMAGE_SIZE_RATIO
        UIGraphicsBeginImageContextWithOptions(CGSize(width: imageWidth, height: imageHeight), false, 0.0)
        resizedOriginalImage.draw(in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        drawImage.draw(in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
    
        // 合成後の画像をViewの背景画像にする
        if let blendImage = UIGraphicsGetImageFromCurrentImageContext() {
            // ドラッグ終了をDrawViewControllerに通知する
            self.delegate?.finishPannig(image: blendImage)
        }
    
        UIGraphicsEndImageContext();

        self.panningRect = CGRect.zero
        self.setNeedsDisplay()
    }
}
