//
//  AppFeedback.h
//  AppFeedback
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


#import <UIKit/UIKit.h>

@interface AppFeedback : NSObject

/**
 Initialize AppFeedback SDK

 @param token slack token
 @param channel slack channel id
 */
+ (void)configureWithSlackToken:(nonnull NSString *)token slackChannel:(nonnull NSString *)channel;

/**
 Slack API URL (default: https://slack.com/api)
 */
@property (class, nonnull) NSString *slackApiUrl;

/**
 List of categories to select on feedback
 */
@property (class, nonnull) NSArray<NSString *> *feedbackCategories;

/**
 Whether to hide feedback button (default: true)
 */
@property (class) BOOL isHidden;

/**
 Display feedback dialog when two fingers long tap gesture is detected
 */
+ (void)readyFeedbackGesture;

/**
 Display feedback dialog when screen shot
 */
+ (void)readyScreenShot;

/**
 Display feedback dialog
 
 Use this method when displaying feedback dialog at any timing.
 */
+ (void)showFeedbackDialog;

/**
 *
 Start recording the screen
 */
+ (void)startRecording;

/**
 End recording the screen
 */
+ (void)endRecording;

@end

