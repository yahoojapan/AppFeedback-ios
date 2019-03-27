//
//  AppFeedback.swift
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

@objcMembers public class AppFeedback: NSObject {
    public static let videoLimitSecs: CGFloat = 30
    public static let floatingButtonWindowLebel: CGFloat = CGFloat.leastNormalMagnitude - CGFloat(1000)
    public static let overlayWindowLebell: CGFloat = AppFeedback.floatingButtonWindowLebel -  CGFloat(1000)
    public static let captureStartNotification = "CaptureStartNotification"
    public static let captureEndNotification = "CaptureEndNotification"
    
    public let config = Config()
    public let overlayWindow = OverlayWindow()
    public let captureOverlayWindow = CaptureOverlayWindow()
    public let floatingButtonController: FloatingButtonController
    public let screenVideoCaptureSession = ScreenVideoCaptureSession()
    public var isHidden: Bool = false
    public let feedbackCategories: [String]
    public let feedbackDialogPresented: Bool
    public let reportViewController: ReportViewController;
    public let navigationController: UINavigationController
    
    // FIXME: Internal
    public static let shared = AppFeedback()
    
    // FIXME: Internal
    public static var frameworkBundle: Bundle {
        #if COCOAPODS
        let bundlePath = Bundle.main.path(forResource: "AppFeedbackResource", ofType: "bundle")
        return Bundle(path: bundlePath)
        #else
        return Bundle(for: AppFeedback.self)
        #endif
    }
 
    // FIXME: Internal
    public let floatingButtinWindow = UIWindow()
    
    private override init() {
        super.init()
        floatingButtonController = createFloatingViewController()
        floatingButtonController.delegate = self
        config.loadInfoPlist()
    }
    
    /// Initialize AppFeedback SDK
    ///
    /// - Parameters:
    ///   - slackToken: slack token
    ///   - slackChannel: slack channel id
    public static func configure(with slackToken: String, slackChannel: String) {
        shared.config.slackToken = slackToken
        shared.config.slackChannel = slackChannel
    }
    
    /// Initialize AppFeedback SDK
    ///
    /// - Parameter slackChannel: slack channel id
    public static func configure(with slackChannel: String) {
        
    }
    
    /// Slack API URL (default: https://slack.com/api)
    static var slackApiUrl: String = "https://slack.com/api"
    
    /// List of categories to select on feedback
    static var feedbackCategories = [String]()
    
    /// Whether to hide feedback button (default: true)
    static var isHidden: Bool = true
    
    /// Display feedback dialog when two fingers long tap gesture is detected
    public static func readyFeedbackGesture() {
        
    }
    
    /// Display feedback dialog when screen shot
    public static func readyScreenShot() {
        NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification,
                                               object: nil,
                                               queue: OperationQueue.main) { _ in
                                                shared.showFeedbackDialog()
        }
    }
    
    /// Display feedback dialog
    /// Use this method when displaying feedback dialog at any timing.
    public static func showFeedbackDialog() {
        guard !shared.screenVideoCaptureSession.recording else { return }
        guard let image = ScreenCapture.captureImage() else { return }
        
        // FIXME: 
        // [self showFeedbackDialogWithImage:image video:nil];
    }
    
    /// Start recording the screen
    public static func startRecording() {
//        BOOL started = [self.screenVideoCaptureSession startRecordingUntil:[AppFeedback videoLimitSecs] callback:^(NSURL *videoPath, NSError *error) {
//            self.captureOverlayWindow.enableCapture = NO;
//            self.floatingButtonController.buttonState = FloatingButtonStateFeedback;
//            [self.floatingButtonController endProgress];
//            [self updateFloatingButtonState];
//            if (error) {
//            UIAlertController *ac = [UIAlertController alertControllerWithTitle:[AppFeedbackLocalizedString stringFor:@"failToCaptureAlertTitle"]
//            message:error.localizedDescription
//            preferredStyle:UIAlertControllerStyleAlert];
//            [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];
//            [self presentViewController:ac animated:YES completion:nil];
//            
//            return;
//            }
//            
//            [self showFeedbackDialogWithImage:nil video:videoPath];
//            }];
//        
//        if (started) {
//            self.captureOverlayWindow.enableCapture = YES;
//            self.floatingButtonController.buttonState = FloatingButtonStateStop;
//            [self.floatingButtonController startProgressWithSecs:[AppFeedback videoLimitSecs]];
//            [self updateFloatingButtonState];
//        }
    }
    
    /// End recording the screen
    public static func endRecording() {
        guard shared.screenVideoCaptureSession.recording else { return }
        shared.floatingButtonController.hidden = true
        shared.screenVideoCaptureSession.stopRecording()
    }
    
    // FIXME: Internal
    public func updateFloatingButtonState() {
        if screenVideoCaptureSession.recording {
            floatingButtonController.hidden = false
        } else {
            floatingButtonController.hidden = isHidden || feedbackDialogPresented
        }
    }
    
    private func createFloatingViewController() -> FloatingButtonController {
        if Int32(floor(NSFoundationVersionNumber)) <= NSFoundationVersionNumber_iOS_9_x_Max {
            return FloatingButtonControllerIOS9()
        } else {
            return FloatingButtonController()
        }
    }
}

extension AppFeedback: FloatingButtonDelegate {
    public func floatingButtonTapped() {
        if screenVideoCaptureSession.recording {
            AppFeedback.endRecording()
        } else {
            AppFeedback.showFeedbackDialog()
        }
    }
}

extension AppFeedback: ReportViewControllerDelegate {
    public func reportViewControllerClosed() {
        feedbackDialogPresented = false
        if !isHidden {
            floatingButtonController.hidden = false
        }
    }
}
