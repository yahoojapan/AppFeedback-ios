//
//  AnimationUtil.m
//  AnimationUtil
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


#import "AnimationUtil.h"

@implementation AnimationUtil
static const NSInteger RESOLUTION = 16;

static const double PI2           = M_PI * 2;

static const double ELASTIC_S     = 1.0f / PI2 * 1.5707963267948966;// 1.57... -> asin(1);

+ (void)animateWithDuration:(NSTimeInterval)duration
                     easing:(EasingFunction)easing {
    
    [self animateWithDuration:duration
                        delay:0
                   resolution:RESOLUTION
                       easing:easing
                   completion:nil];
}

+ (void)animateWithDuration:(NSTimeInterval)duration
                     easing:(EasingFunction)easing
                 completion:(void (^)(void))completion {
    
    [self animateWithDuration:duration
                        delay:0
                   resolution:RESOLUTION
                       easing:easing
                   completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                 resolution:(NSInteger)resolution
                     easing:(EasingFunction)easing
                 completion:(void(^)(void))completion {
    
    NSAssert(easing, @"invalid easing block.");
    
    if (duration == 0) {
        easing(1);
        if (completion) completion();
        return;
    }
    
    void (^animations) (void) = ^{
        NSTimeInterval relativeDuration = 1 / (CGFloat) resolution;
        
        for (NSInteger i = 1; i <= resolution; ++i) {
            CGFloat t = i / (CGFloat) resolution;
            [UIView addKeyframeWithRelativeStartTime:t - relativeDuration
                                    relativeDuration:relativeDuration
                                          animations:^{
                                              easing(t);
                                          }];
        }
    };
    
    easing(0);
    [UIView animateKeyframesWithDuration:duration
                                   delay:delay
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear | UIViewAnimationOptionCurveLinear
                              animations:animations
                              completion:^(BOOL finished) {
                                  if (finished && completion) completion();
                              }];
}

+ (CGFloat)easeElasticOut:(CGFloat)t {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    return pow(2, -10 * t) * sin((t - ELASTIC_S) * PI2) + 1;
}
@end
