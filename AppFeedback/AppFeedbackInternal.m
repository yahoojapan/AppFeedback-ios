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

@implementation AppFeedback

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

- (UINavigationController *)navigationController {
    if (!_reportViewController) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:AppFeedback.frameworkBundle];
        _navigationController = [storyboard instantiateInitialViewController];
        _reportViewController = _navigationController.viewControllers[0];
        _reportViewController.delegate = self;
    }
    return _navigationController;
}

@end
