//
//  ScreenCapture.m
//  ScreenCapture
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


#import "ScreenCapture.h"
#import "FloatingButtonWindow.h"
#import <UIKit/UIKit.h>
#import <AppFeedback/AppFeedback-Swift.h>

@implementation ScreenCapture

+ (UIImage *)captureImageWithScale:(CGFloat)scale
                              size:(CGSize)size
                   baseOrientation:(UIInterfaceOrientation)baseOrientation {
    // begin of generate image
    BOOL opaque = NO;

    CGAffineTransform transform = [self transformWith:baseOrientation
                                     imageOrientation:UIApplication.sharedApplication.statusBarOrientation
                                             baseSize:size];

    UIGraphicsBeginImageContextWithOptions(size, opaque, scale);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, transform);

    // render current window
    UIApplication *app = [UIApplication sharedApplication];
    for (UIWindow *window in app.windows) {
        if ([window isKindOfClass:FloatingButtonWindow.class] ||
            [window isKindOfClass:OverlayWindow.class]) {
            continue;
        }
        [window drawViewHierarchyInRect:window.frame afterScreenUpdates:NO];
    }
    
    // get current image
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    // end of generate image
    UIGraphicsEndImageContext();
    
    return img;
}

typedef struct OrientationTransform {
    UIInterfaceOrientation base;
    UIInterfaceOrientation current;
    CGAffineTransform transform;
} OrientationTransform;

+ (NSInteger)orientationIndex:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationPortrait: return 0;
        case UIInterfaceOrientationLandscapeLeft: return 1;
        case UIInterfaceOrientationPortraitUpsideDown: return 2;
        case UIInterfaceOrientationLandscapeRight: return 3;
        default: return 0;
    }
}

// 動画撮影開始時の画面の向きに合わせて現在のデバイスの向きの画像を変換する
+ (CGAffineTransform)transformWith:(UIInterfaceOrientation)baseOrientation
                  imageOrientation:(UIInterfaceOrientation)imageOrientation
                          baseSize:(CGSize)baseSize {
    UIInterfaceOrientation a = [self orientationIndex:baseOrientation];
    UIInterfaceOrientation b = [self orientationIndex:imageOrientation];
    NSInteger diff = (a - b + 4) % 4;

    if (diff == 0) {
        return CGAffineTransformIdentity;
    }
    if (diff == 1) {
        return CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI_2),
                                       CGAffineTransformMakeTranslation(baseSize.width, 0));
    }
    if (diff == 2) {
        return CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI),
                                       CGAffineTransformMakeTranslation(baseSize.width, baseSize.height));
    }
    if (diff == 3) {
        return CGAffineTransformConcat(CGAffineTransformMakeRotation(M_PI + M_PI_2),
                                       CGAffineTransformMakeTranslation(0, baseSize.height));
    }
    return CGAffineTransformIdentity;
}


+ (UIImage *)captureImage {
    CGRect rect = [[UIScreen mainScreen] bounds];
    return [self captureImageWithScale:0.0
                                  size:rect.size
                       baseOrientation:UIApplication.sharedApplication.statusBarOrientation];
}

@end
