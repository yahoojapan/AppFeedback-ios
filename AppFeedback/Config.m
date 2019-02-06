//
//  Config.m
//  Config
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


#import "Config.h"
#import "AppFeedbackInternal.h"

@interface Config()

@end

@implementation Config

#pragma mark - Public Methods

- (id)init {
    if (self = [super init]) {
        self.categories = @[ AppFeedbackLocalizedString(@"bug", @""),
                             AppFeedbackLocalizedString(@"request", @""),
                             AppFeedbackLocalizedString(@"question", @""),
                             AppFeedbackLocalizedString(@"design", @""),
                             AppFeedbackLocalizedString(@"others", @"")];
        self.slackApiUrl = @"https://slack.com/api";
    }
    return self;
}

- (void)loadInfoPlist {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    [self loadInfoPlistDic:info];
}

- (BOOL)isValid {
    return self.slackToken && self.slackChannel;
}

#pragma mark - Private Methods

- (void)loadInfoPlistDic:(NSDictionary *)info {
    // TODO: read branch information
    if ([self getRequiredKey:info key:@"AppFeedback_SlackApiToken"]) {
        self.slackToken = [self getRequiredKey:info key:@"AppFeedback_SlackApiToken"];
    }
    if ([self getRequiredKey:info key:@"AppFeedback_SlackChannel"]) {
        self.slackChannel = [self getRequiredKey:info key:@"AppFeedback_SlackChannel"];
    }
    if ([self getRequiredKey:info key:@"AppFeedback_SlackApiUrl"]) {
        self.slackApiUrl = [self getRequiredKey:info key:@"AppFeedback_SlackApiUrl"];
    }
    if ([self getRequiredKey:info key:@"AppFeedback_Branch"]) {
        self.branchName = [self getRequiredKey:info key:@"AppFeedback_Branch"];
    }
}

- (NSString *)getRequiredKey:(NSDictionary *)info key:(NSString *)key {
    NSString *value = [info objectForKey:key];
    if (!value) {
        NSLog(@"AppFeedback: %@ not found in Info.plist", key);
        return nil;
    }
    return value;
}

@end
