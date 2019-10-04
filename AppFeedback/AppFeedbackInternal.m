//
//  AppFeedbackInternal.m
//  AppFeedbackInternal
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


#import "AppFeedback.h"
#import "ReportViewController.h"
#import "DeviceUtil.h"
#import "Config.h"
#import "FloatingButtonController.h"
#import "FloatingButtonControllerIOS9.h"
#import "ScreenVideoCaptureSession.h"
#import "ScreenCapture.h"
#import "OverlayWindow.h"
#import "CaptureOverlayWindow.h"
#import "AppFeedbackInternal.h"

// Notification
static NSString * _Nonnull const kCaptureStartNotification = @"CaptureStartNotification";
static NSString * _Nonnull const kCaptureEndNotification   = @"CaptureEndNotification";

@interface AppFeedback() <FloatingButtonDelegate, ReportViewControllerDelegate>
@property (nonatomic, strong) Config *config;
@property (nonatomic, strong) OverlayWindow *overlayWindow;
@property (nonatomic, strong) CaptureOverlayWindow *captureOverlayWindow;
@property (nonatomic, strong) FloatingButtonController *floatingButtonController;
@property (nonatomic, strong) ScreenVideoCaptureSession *screenVideoCaptureSession;
@property (nonatomic) BOOL isHidden;
@property (nonatomic, strong) NSArray<NSString *> *feedbackCategories;
@property (nonatomic) BOOL feedbackDialogPresented;
@property (nonatomic, strong) ReportViewController *reportViewController;
@property (nonatomic, strong) UINavigationController *navigationController;

@end

@implementation AppFeedback

static AppFeedback *sharedData = nil;

+ (AppFeedback *)shared {
    if (!sharedData) {
        sharedData = [AppFeedback new];
    }
    return sharedData;
}

+ (nonnull NSBundle*)frameworkBundle {
#ifdef COCOAPODS
    NSString* bundlePath = [NSBundle.mainBundle pathForResource:@"AppFeedbackResource" ofType:@"bundle"];
    return [NSBundle bundleWithPath:bundlePath];
#else
    return [NSBundle bundleForClass:self.class];
#endif
}

+ (void)configureWithSlackToken:(NSString *)token slackChannel:(NSString *)channel {
    [AppFeedback.shared configureWithSlackToken:token slackChannel:channel];
}

+ (void)configureWithSlackChannel:(nonnull NSString *)channel {
    [AppFeedback.shared configureWithSlackToken:nil slackChannel:channel];
}

// getter method for feedbackCategories
+ (NSArray<NSString *> *)feedbackCategories {
    return [AppFeedback.shared getFeedbackCategories];
}

// setter method for feedbackCategories
+ (void)setFeedbackCategories:(NSArray<NSString *> *)feedbackCategories {
    [AppFeedback.shared setFeedbackCategories:feedbackCategories];
}

+ (NSString *)slackApiUrl {
    return AppFeedback.shared.config.slackApiUrl;
}

+ (void)setSlackApiUrl:(NSString *)url {
    AppFeedback.shared.config.slackApiUrl = url;
}

+ (BOOL)isHidden {
    return AppFeedback.shared.isHidden;
}

+ (void)setIsHidden:(BOOL)isHidden {
    AppFeedback.shared.isHidden = isHidden;
}

+ (void)showFeedbackDialog {
    [AppFeedback.shared showFeedbackDialog];
}

+ (void)readyFeedbackGesture {
    [AppFeedback.shared readyFeedbackGesture];
}

+ (void)readyScreenShot {
    [AppFeedback.shared readyScreenShot];
}

+ (void)startRecording {
    [AppFeedback.shared startRecording];
}

+ (void)endRecording {
    [AppFeedback.shared endRecording];
}


#pragma mark - Public Methods

- (id)init {
    if (self = [super init]) {
        self.floatingButtonController = [self createFloatingViewController];
        self.floatingButtonController.delegate = self;
        self.isHidden = NO;
        self.screenVideoCaptureSession = [[ScreenVideoCaptureSession alloc] init];
        
        self.overlayWindow = [[OverlayWindow alloc] init];
        self.captureOverlayWindow = [[CaptureOverlayWindow alloc] init];

        self.config = [Config new];
        [self.config loadInfoPlist];
    }
    return self;
}

- (void)configureWithSlackToken:(NSString *)token slackChannel:(NSString *)channel {
    if (token) {
        self.config.slackToken = token;
    }

    if (channel) {
        self.config.slackChannel = channel;
    }
}

- (FloatingButtonController *)createFloatingViewController {
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        return [[FloatingButtonControllerIOS9 alloc] init];
    } else {
        return [[FloatingButtonController alloc] init];
        
    }
}

- (void)setFeedbackCategories:(NSArray<NSString *> *)categories {
    if (!self.config) {
        self.config = [Config new];
    }
    self.config.categories = categories;
}

- (NSArray<NSString *> *)getFeedbackCategories {
    return self.config.categories;
}

- (void)readyFeedbackGesture
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UILongPressGestureRecognizer *longPressGesture =
        [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(p_handleLongPressGesture:)];
        // 2本指
        longPressGesture.numberOfTouchesRequired = 2;
        
        // ビューにジェスチャーを追加
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [self p_removeLongPressGesture:window];
        [window addGestureRecognizer:longPressGesture];
    });
}

#pragma mark - Internal Methods

- (UIWindow *)floatingButtinWindow {
    return self.floatingButtonController.window;
}

#pragma mark - Private Methods
- (void)p_handleLongPressGesture:(UIGestureRecognizer *)sender {
    
    if([sender state] == UIGestureRecognizerStateEnded) {
        [self showFeedbackDialog];
    }
}

- (void)p_removeLongPressGesture:(UIWindow*)window {
    for (UIGestureRecognizer *recognizer in window.gestureRecognizers) {
        if([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [window removeGestureRecognizer:recognizer];
        }
    }
}

- (void)setIsHidden:(BOOL)isHidden {
    _isHidden = isHidden;
    [self updateFloatingButtonState];
}

- (void)updateFloatingButtonState {
    if (self.screenVideoCaptureSession.recording) {
        self.floatingButtonController.hidden = NO;
    } else {
        self.floatingButtonController.hidden = self.isHidden || self.feedbackDialogPresented;
    }
}

- (void)showFeedbackDialog {
    if (self.screenVideoCaptureSession.recording) {
        return;
    }
    UIImage *image = [ScreenCapture captureImage];
    [self showFeedbackDialogWithImage:image video:nil];
}

- (void)showFeedbackDialogWithImage:(UIImage *)image video:(NSURL *)videoPath {
    if (!self.config || !self.config.isValid) {
        NSLog(@"AppFeedback not configured collectly for feedback");
        return;
    }
    
    if (self.feedbackDialogPresented) {
        return;
    }
    
    self.feedbackDialogPresented = YES;
    [self updateFloatingButtonState];
    
    //モザイク処理を掛ける
    [[NSNotificationCenter defaultCenter] postNotificationName:kCaptureStartNotification object:nil];
    
    
    UIViewController *sourceViewController = nil;
    //現在表示中のviewcontrollerを取得
    sourceViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    if ([sourceViewController isKindOfClass:[ReportViewController class]]) {
        return;
    }
    
    if ([sourceViewController isKindOfClass:[UINavigationController class]]) {
        //navigationbar
        UINavigationController *nav = (UINavigationController*)sourceViewController;
        sourceViewController = nav.viewControllers.lastObject;
        if (sourceViewController.presentedViewController) {
            //モーダル優先
            sourceViewController = sourceViewController.presentedViewController;
        }
    }
    else {
        //normal
        if (sourceViewController.presentedViewController) {
            //モーダル優先
            sourceViewController = sourceViewController.presentedViewController;
        }
    }
    
    if ([sourceViewController isKindOfClass:[UINavigationController class]]) {
        //navigationbar
        UINavigationController *nav = (UINavigationController*)sourceViewController;
        sourceViewController = nav.viewControllers.lastObject;
    }
    
    //呼び出し元クラス名をログで送出する
    NSString *className = NSStringFromClass([sourceViewController class]);

    if ([className isEqualToString:@"ReportViewController"]) {
        return;
    }

    UINavigationController *nav = self.navigationController;
    
    nav.modalPresentationStyle = UIModalPresentationFullScreen;

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

- (void)readyScreenShot
{
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationUserDidTakeScreenshotNotification
                                                      object:nil
                                                       queue:mainQueue
                                                  usingBlock:^(NSNotification *note) {
                                                      [self handleScreenShotNotification];
                                                  }];
}

- (void)startRecording {
    BOOL started = [self.screenVideoCaptureSession startRecordingUntil:VIDEO_LIMIT_SECS callback:^(NSURL *videoPath, NSError *error) {
        self.captureOverlayWindow.enableCapture = NO;
        self.floatingButtonController.buttonState = FloatingButtonStateFeedback;
        [self.floatingButtonController endProgress];
        [self updateFloatingButtonState];
        if (error) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:AppFeedbackLocalizedString(@"failToCaptureAlertTitle", @"")
                                                                        message:error.localizedDescription
                                                                 preferredStyle:UIAlertControllerStyleAlert];
            [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}]];
            [self presentViewController:ac animated:YES completion:nil];

            return;
        }
        
        [self showFeedbackDialogWithImage:nil video:videoPath];
    }];

    if (started) {
        self.captureOverlayWindow.enableCapture = YES;
        self.floatingButtonController.buttonState = FloatingButtonStateStop;
        [self.floatingButtonController startProgressWithSecs:VIDEO_LIMIT_SECS];
        [self updateFloatingButtonState];
    }
}

- (void)endRecording {
    if (self.screenVideoCaptureSession.recording) {
        self.floatingButtonController.hidden = YES;
        [self.screenVideoCaptureSession stopRecording];
    }
}

- (void)handleScreenShotNotification
{
    [self showFeedbackDialog];
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion {
    [self.overlayWindow presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (UINavigationController *)navigationController {
    if (!_reportViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:AppFeedback.frameworkBundle];
        _navigationController = [storyboard instantiateInitialViewController];
        _reportViewController = _navigationController.viewControllers[0];
        _reportViewController.delegate = self;
    }
    return _navigationController;
}

#pragma mark - FloatingButtonDelegate

- (void)floatingButtonTapped {
    if (self.screenVideoCaptureSession.recording) {
        [self endRecording];
    } else {
        [self showFeedbackDialog];
    }
}

#pragma mark - ReportViewControllerDelegate

- (void)reportViewControllerClosed {
    self.feedbackDialogPresented = NO;
    if (!_isHidden) {
        self.floatingButtonController.hidden = NO;
    }
}

@end
