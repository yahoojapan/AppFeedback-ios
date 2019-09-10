//
//  UIPlaceHolderTextView.swift
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
public class UIPlaceHolderTextView: AutoResizeTextView {
    public var placeholder: String = ""
    public var placeholderColor: UIColor = .lightGray
    
    private var placeHolderLabel: UILabel?
    
    
    override public var text: String! {
        didSet {
            textChanged(notification: nil)
        }
    }
    
    func textChanged(notification: Notification?) {
        if placeholder.isEmpty {
            return
        }
        
        if text.isEmpty {
            viewWithTag(999)?.alpha = 1
        } else {
            viewWithTag(999)?.alpha = 0
        }
        
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        addObservers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addObservers()
        
    }
    
    private func addObservers() {
        NotificationCenter
            .default
            .addObserver(
                self,
                selector: #selector(textChanged(notification:)),
                name: UITextView.textDidChangeNotification,
                object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func draw(_ rect: CGRect) {
        if !placeholder.isEmpty {
            if placeHolderLabel == nil {
                let placeHolderLabel = UILabel(frame: CGRect(x: 8, y: 8, width: bounds.size.width - 16, height: 0))
                placeHolderLabel.lineBreakMode = .byWordWrapping
                placeHolderLabel.numberOfLines = 0
                placeHolderLabel.font = font
                placeHolderLabel.backgroundColor = .clear
                placeHolderLabel.textColor = placeholderColor
                placeHolderLabel.alpha = 0
                placeHolderLabel.tag = 999
                addSubview(placeHolderLabel)
                self.placeHolderLabel = placeHolderLabel
            }
            
            placeHolderLabel?.text = placeholder
            placeHolderLabel?.sizeToFit()
            
            if let placeHolderLabel = placeHolderLabel {
                sendSubviewToBack(placeHolderLabel)
            }
        }
        
        if text.isEmpty && !placeholder.isEmpty {
            viewWithTag(999)?.alpha = 1
        }
        
        super.draw(rect)
    }
}
