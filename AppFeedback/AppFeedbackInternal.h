//
//  AppFeedbackInternal.h
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


#import <Foundation/Foundation.h>
#include "AppFeedback.h"

// Internal interface

#define VIDEO_LIMIT_SECS 30.0f

#define FLOATING_BUTTON_WINDOW_LEVEL (CGFLOAT_MAX - 1000)
#define OVERLAY_WINDOW_LEVEL (FLOATING_BUTTON_WINDOW_LEVEL - 1000)

#define RGBA(r, g, b, a)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)/255.0]

#define AppFeedbackLocalizedString(key, comment) \
[AppFeedback.frameworkBundle localizedStringForKey:(key) value:@"" table:nil]

@interface AppFeedback()

@property (class, nonnull, readonly) AppFeedback *shared;
@property (class, nonnull, readonly) NSBundle *frameworkBundle;

@property (nonatomic, nonnull, readonly) UIWindow *floatingButtinWindow;
- (void)updateFloatingButtonState;

@end
