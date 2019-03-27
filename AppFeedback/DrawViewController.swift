//
//  DrawViewController.swift
//  DrawViewController
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

@objc public class DrawViewController: UIViewController {
    @objc @IBOutlet public var imageView: UIImageView!
    @IBOutlet var drawingView: DrawView!
    @IBOutlet var clearButton: UIBarButtonItem!
    @objc public var originImage: UIImage?
    @objc public var editingImage: UIImage?

    private var startPoint: CGPoint = CGPoint.zero
    private var currentPoint: CGPoint  = CGPoint.zero

    override public func viewDidLoad() {
        super.viewDidLoad()

        if let editingImage = self.editingImage {
            self.imageView.image = editingImage
            self.clearButton.isEnabled = true
        } else {
            self.imageView.image = self.originImage
            self.clearButton.isEnabled = false
        }
        
        guard let originImage = self.originImage else { return }
    
        // Dynamically change the drawing area aspect ratio to match the image
        let drawingRectAspect = NSLayoutConstraint(item: self.drawingView, attribute: .height, relatedBy: .equal, toItem: self.drawingView, attribute: .width, multiplier: originImage.size.height/originImage.size.width, constant: 1)
        drawingRectAspect.priority = UILayoutPriority(rawValue: 1000)
        self.drawingView.addConstraint(drawingRectAspect)
    
        self.drawingView.delegate = self
    
        self.drawingView.linkUI(imageView: self.imageView)
    }

    @IBAction func clearButtonTapped(_ sender: Any) {
        self.imageView.image = self.originImage
        self.clearButton.isEnabled = false
        self.editingImage = nil

    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension DrawViewController: DrawViewDelegate {
    public func finishPannig(image: UIImage) {
        self.imageView.image = image
        self.clearButton.isEnabled = true
        self.editingImage = image
    }
}
