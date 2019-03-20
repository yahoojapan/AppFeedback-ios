//
//  FloatingButtonView.m
//  FloatingButtonView
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


#import "FloatingButtonView.h"
#import <AppFeedback/AppFeedback-Swift.h>

@interface FloatingButtonView ()

@property (weak, nonatomic) IBOutlet UIImageView *feedbackImage;
@property (weak, nonatomic) IBOutlet UIImageView *stopImage;
@property (weak, nonatomic) IBOutlet FloatingProgressView *progressView;

@end

@implementation FloatingButtonView


- (void)setButtonState:(FloatingButtonState)buttonState {
    self.stopImage.hidden = YES;
    self.feedbackImage.hidden = YES;

    switch (buttonState) {
        case FloatingButtonStateFeedback:
            self.feedbackImage.hidden = NO;
            break;
        case FloatingButtonStateStop:
            self.stopImage.hidden = NO;
            break;
    }
}

- (void)startProgressWithSecs:(float)seconds {
    [self.progressView startProgressWithSecs:seconds];
}

- (void)endProgress {
    [self.progressView endProgress];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = self.bounds;

    // タップ検知範囲を広げる
    float margin = 10.0;
    rect.origin.x -= margin;
    rect.size.width += margin * 2;
    rect.size.height += margin;

    return CGRectContainsPoint(rect, point);
}


@end
