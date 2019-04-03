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
    public static let overlayWindowLebel: CGFloat = AppFeedback.floatingButtonWindowLebel -  CGFloat(1000)
    
    public let config: Config = Config()
    public let overlayWindow = OverlayWindow()
    public let captureOverlayWindow = CaptureOverlayWindow()
    public let floatingButtonController: FloatingButtonController
    public let screenVideoCaptureSession = ScreenVideoCaptureSession()
    public var isHidden: Bool = false
    public var feedbackDialogPresented: Bool = false
    public let reportViewController: ReportViewController
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
        floatingButtonController = AppFeedback.createFloatingViewController()
        super.init()
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
                                                AppFeedback.showFeedbackDialog()
        }
    }
    
    /// Display feedback dialog
    /// Use this method when displaying feedback dialog at any timing.
    public static func showFeedbackDialog() {
        guard !shared.screenVideoCaptureSession.recording else { return }
        guard let image = ScreenCapture.captureImage() else { return }
        
        showFeedbackDialog(with: image, videoPath: nil)
    }
    
    private func showFeedbackDialog(with image: UIImage, videoPath: URL) {
        if !config.isValid() {
            print("AppFeedback not configured collectly for feedback")
            return;
        }
        
        if feedbackDialogPresented {
            return;
        }
        
        feedbackDialogPresented = true
        updateFloatingButtonState()
        
        //モザイク処理を掛ける
        NotificationCenter.default.post(name: .captureStart, object: nil)
        
        var sourceViewController: UIViewController? = nil
        //現在表示中のviewcontrollerを取得
        sourceViewController = UIApplication.shared.delegate?.window??.rootViewController
        if sourceViewController is ReportViewController {
            return
        }
        
        if sourceViewController is UINavigationController {
            //navigationbar
            let nav = sourceViewController as? UINavigationController
            sourceViewController = nav?.viewControllers.last
            if (sourceViewController?.presentedViewController) != nil {
                //モーダル優先
                sourceViewController = sourceViewController?.presentedViewController
            }
        }
        else {
            //normal
            if (sourceViewController?.presentedViewController) != nil {
                //モーダル優先
                sourceViewController = sourceViewController?.presentedViewController
            }
        }
        
        if sourceViewController is UINavigationController {
            //navigationbar
            let nav = sourceViewController as? UINavigationController
            sourceViewController = nav?.viewControllers.last
        }
        
        // ここからSwift化 ----
        
        //呼び出し元クラス名をログで送出する
        NSString *className = NSStringFromClass([sourceViewController class]);
        
        if ([className isEqualToString:@"ReportViewController"]) {
            return;
        }
        
        UINavigationController *nav = self.navigationController;
        
        if (image) {
            _reportViewController.image = image;
        }
        
        _reportViewController.videoPath = videoPath;
        
        [_reportViewController setConfig:self.config];
        
        // キーボード表示中にフィードバックダイアログを表示すると、コメント入力時のキーボードが
        // 白くなる問題があるので強制的に非表示にする
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        
        [self presentViewController:nav animated:YES completion:^{
            [self->_reportViewController setSourceClassName:className];
            
            }];
    }
    
    private func present(viewController: UIViewController,
                         animated: Bool,
                         completion: @escaping ()-> Void) {
        overlayWindow.present(viewController, animated: animated, completion: completion)
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
    
    private static func createFloatingViewController() -> FloatingButtonController {
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
