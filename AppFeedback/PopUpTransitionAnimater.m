//
//  PopUpTransitionAnimater.m
//  PopUpTransitionAnimater
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


#import "PopUpTransitionAnimater.h"
#import "ReportViewController.h"
#import "AnimationUtil.h"

@interface PopUpTransitionAnimater()
@property (nonatomic) BOOL presenting;
@end

@implementation PopUpTransitionAnimater

- (id<UIViewControllerAnimatedTransitioning>)initWithPresenting:(BOOL)presenting {
    if (self = [super init]) {
        self.presenting = presenting;
    }
    return self;
}

- (id)init {
    //指定イニシャライザを通す
    return [self initWithPresenting:NO];
}

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *alertView = self.presenting? ((UIViewController *)toVC).view : ((UIViewController *)fromVC).view;
    UIView *containerView = [transitionContext containerView];
    
    toVC.view.frame = containerView.frame;
    fromVC.view.frame = containerView.frame;
    
    CGFloat a0 = self.presenting? 0 : 0.8;
    CGFloat a1 = self.presenting? 0.8 : 0;
    
    containerView.alpha = a0;
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         containerView.alpha = a1;
                     }
                     completion:^(BOOL finished)
     {
         if (!finished) return;
         
         CGFloat y0 = self.presenting? alertView.frame.size.height : containerView.frame.origin.y;
         CGFloat y1 = self.presenting? containerView.frame.origin.y  : alertView.frame.size.height;
         
         // TODO: あとでちがうアニメーションにしたい
         [AnimationUtil animateWithDuration:0.5f
                                     easing:^(CGFloat t) {
                                         t = [AnimationUtil easeElasticOut:t];
                                         CGFloat newY = y0 + (y1 - y0) * t;
                                         CGRect newFrame = alertView.frame;
                                         newFrame.origin.y = newY;
                                         alertView.frame = newFrame;
                                     }
                                 completion:^(){
                                     [transitionContext completeTransition:YES];
                                 }];
     }];
}

@end
