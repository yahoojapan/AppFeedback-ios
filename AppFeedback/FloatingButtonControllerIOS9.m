//
//  FloatingButtonControllerIOS9.m
//  FloatingButtonControllerIOS9
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


#import "FloatingButtonControllerIOS9.h"

/*
 
 iOS9 以下ではフィードバックボタンにステータスバーの表示状態が補足されてしまう。
 そこで、無理やりタイマーを回して更新する。
 アプリ側からするとわかりにくい挙動なので、ドキュメントで中期しておく必要がある。 
 */

@implementation FloatingButtonControllerIOS9

- (void)viewDidLoad {
    [super viewDidLoad];

    [NSTimer scheduledTimerWithTimeInterval:0.1
                                     target:self
                                   selector:@selector(updateStatusBar:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)updateStatusBar:(NSTimer *)timer {
    if (self.hidden) {
        return;
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    vc = [self vcForStatusBarStyle:vc];
    if (vc == self) {
        return UIStatusBarStyleDefault;
    }
    return [vc preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *vc = UIApplication.sharedApplication.keyWindow.rootViewController;
    vc = [self vcForStatusBarHidden:vc];
    if (vc == self) {
        return UIStatusBarStyleDefault;
    }
    return [vc prefersStatusBarHidden];
}

- (UIViewController *)vcForStatusBarHidden:(UIViewController *)vc {
    while (true) {
        UIViewController *child = vc.childViewControllerForStatusBarHidden;
        if (!child) break;
        vc = child;
    }
    return vc;
}

- (UIViewController *)vcForStatusBarStyle:(UIViewController *)vc {
    while (true) {
        UIViewController *child = vc.childViewControllerForStatusBarStyle;
        if (!child) break;
        vc = child;
    }
    return vc;
}

@end
