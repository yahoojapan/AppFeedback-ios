//
//  CaptureOverlayWindow.m
//  CaptureOverlayWindow
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


#import "CaptureOverlayWindow.h"
#import "AppFeedbackInternal.h"
#import <AppFeedback/AppFeedback-Swift.h>

@implementation CaptureOverlayWindow

- (id)init {
    if (self = [super init]) {
        self.windowLevel = OverlayWindow.overlayWindowLevel;
        self.backgroundColor = nil;

        self.rootViewController = [[UIViewController alloc] init];
        self.clipsToBounds = NO;
        self.hidden = YES;
    }
    return self;
}

- (void)setEnableCapture:(BOOL)enableCapture {
    self.hidden = !enableCapture;
}

- (void)showAnimationAt:(CGPoint)point {
    CGFloat radius = 12;
    UIColor *fillColor = RGBA(0xee, 0xff, 0xff, 0xff);
    UIColor *borderColor = RGBA(0xcc, 0xcc, 0xcc, 0xff);
    NSTimeInterval duration = 0.5;

    UIView *animView = [[UIView alloc] initWithFrame:CGRectMake(point.x - radius,
                                                                point.y - radius,
                                                                radius * 2,
                                                                radius * 2)];
    animView.layer.cornerRadius = radius;
    animView.backgroundColor = fillColor;
    animView.layer.borderColor = borderColor.CGColor;
    animView.layer.borderWidth = 2.0;
    
    [self.rootViewController.view addSubview:animView];

    animView.alpha = 1.0;
    [UIView animateWithDuration:duration delay:0
                        options:UIViewAnimationOptionCurveEaseInOut animations:^{
                            animView.alpha = 0.0;
                        } completion:^(BOOL finished){
                            if (finished) {
                                [animView removeFromSuperview];
                            }
                        }];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // フィードバックボタンをタップしたときでもなぜか呼ばれるため、ボタンの領域のときには
    // アニメーションさせないようにしておく
    if (![self isUnderFloatingButton:point withEvent:event]) {
        [self showAnimationAt:point];
    }

    return false;
}

- (BOOL)isUnderFloatingButton:(CGPoint)point withEvent:(UIEvent *)event {
    UIWindow *buttonWindow = AppFeedback.shared.floatingButtinWindow;
    CGPoint buttonPoint = [self convertPoint:point toView:buttonWindow];
    return [AppFeedback.shared.floatingButtinWindow pointInside:buttonPoint withEvent:event];
}

@end
