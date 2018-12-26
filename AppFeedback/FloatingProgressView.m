//
//  FloatingProgressView.m
//  FloatingProgressView
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


#import "FloatingProgressView.h"

#define LINE_WIDTH 3.0f

@interface FloatingProgressView()

@property (nonatomic) CALayer *shapeLayer;

@end

@implementation FloatingProgressView


- (void)startProgressWithSecs:(float)seconds {
    [self startAnimationWithSecs:seconds];
}
- (void)endProgress {
    [self.shapeLayer removeAllAnimations];
    [self.shapeLayer removeFromSuperlayer];
    self.shapeLayer = nil;
}

- (void)startAnimationWithSecs:(float)seconds {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];

    UIBezierPath *path = [self makeCircleAtLocation:self.center
                                             radius:self.frame.size.width / 2 - LINE_WIDTH / 2
                                            percent:1];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.lineWidth = LINE_WIDTH;
    shapeLayer.backgroundColor = [UIColor blueColor].CGColor;
    [self.layer addSublayer:shapeLayer];
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = seconds;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0];
    [shapeLayer addAnimation:pathAnimation forKey:@"drawCircleAnimation"];
    
    self.shapeLayer = shapeLayer;
}
    

- (UIBezierPath *)makeCircleAtLocation:(CGPoint)location radius:(CGFloat)radius percent:(CGFloat)percent {
    UIBezierPath *path = [UIBezierPath bezierPath];

    [path addArcWithCenter:location
                    radius:radius
                startAngle:M_PI + M_PI_2
                  endAngle:M_PI + M_PI_2 + (M_PI * 2.0) * percent
                 clockwise:YES];
    
    path.lineWidth = LINE_WIDTH;
    return path;
}
@end
