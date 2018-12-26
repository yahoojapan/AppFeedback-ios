//
//  OverlayWindow.m
//  OverlayWindow
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


#import "OverlayWindow.h"
#import "AppFeedbackInternal.h"


typedef enum AlertButtonIndex : NSUInteger {
    UIAlertCancelButtonIndex = 0,
    UIAlertDestructiveButtonIndex = 1,
    UIAlertFirstOtherButtonIndex = 2
} AlertButtonIndex;

@interface OverlayWindow ()

@property (nonatomic, strong) NSTimer *modalTimer;
@property (nonatomic) CALayer *shapeLayer;

@end

@implementation OverlayWindow

- (id)init {
    if (self = [super init]) {
        self.windowLevel = OVERLAY_WINDOW_LEVEL;
        self.backgroundColor = nil;

        self.rootViewController = [[UIViewController alloc] init];
        self.clipsToBounds = NO;
        self.hidden = YES;
        self.modalTimer = nil;
    }
    return self;
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent
                     animated:(BOOL)flag
                   completion:(void (^)(void))completion {
    
    // 全画面の UIWindow が存在するとステータスバーの表示の可否まで補足してしまう
    // そこで、モーダルが表示されている場合のみ hidden = NO とする。
    // モーダルが表示されているかは手軽に判別できる方法がないため、タイマーで監視する。
    
    self.hidden = NO;
    [self.rootViewController presentViewController:viewControllerToPresent animated:flag completion:^{
        [NSTimer scheduledTimerWithTimeInterval:0.2
                                         target:self
                                       selector:@selector(monitorModal:)
                                       userInfo:nil
                                        repeats:YES];
        if(completion){
            completion();
        }
    }];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.rootViewController.presentedViewController) {
        // 何かしらのモーダルが表示されている場合のみ反応する
        return true;
    } else {
        return false;
    }
}

- (void)monitorModal:(NSTimer *)timer {
    if (!self.rootViewController.presentedViewController) {
        [timer invalidate];
        self.hidden = YES;
    }
}

@end
