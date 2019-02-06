//
//  SlackAPI.h
//  SlackAPI
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


#ifndef SlackAPI_h
#define SlackAPI_h

#import <Foundation/Foundation.h>
#import "Config.h"

@interface SendData : NSObject

@property (nonatomic, strong) NSData* imageData;
@property (nonatomic, strong) NSURL* videoPath;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* category;
@property (nonatomic, strong) NSString* comment;
@property (nonatomic, strong) NSString* username;
@property (nonatomic, strong) NSString* appTitle;
@property (nonatomic, strong) NSString* appVersion;
@property (nonatomic, strong) NSString* appBuildVersion;
@property (nonatomic, strong) NSString* systemVersion;
@property (nonatomic, strong) NSString* modelCode;
@property (nonatomic, strong) NSString* modelName;

@end

@interface SlackAPI : NSObject

- (instancetype)initWithToken:(NSString *)token channel:(NSString *)channel apiUrl:(NSString *)apiUrl branch:(NSString *)branchName;
- (void)postData:(SendData *)data completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end

#endif /* SlackAPI_h */
