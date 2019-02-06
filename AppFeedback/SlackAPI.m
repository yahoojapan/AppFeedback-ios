//
//  SlackAPI.m
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


#import <Foundation/Foundation.h>
#import "SlackAPI.h"

@implementation SendData
@end

@interface SlackAPI ()

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *apiUrl;
@property (nonatomic, strong) NSString *branchName;

@end

@implementation SlackAPI

- (instancetype)initWithToken:(NSString *)token channel:(NSString *)channel apiUrl:(NSString *)apiUrl branch:(NSString *)branchName{
    if (self = [super init]) {
        self.token = token;
        self.channel = channel;
        self.apiUrl = apiUrl;
        self.branchName = branchName;
    }
    return self;
}

- (void)postData:(SendData *)data completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler {

    NSString *urlString = [NSString stringWithFormat:@"%@/files.upload", self.apiUrl];
    
    NSURL *feedbackURL = [NSURL URLWithString:urlString];
    
    NSString *boundary = @"AppFeedbackiOSSDKBoundary";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:feedbackURL];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];

    NSString *authHeader = [NSString stringWithFormat:@"Bearer %@", self.token];
    [request setValue:authHeader forHTTPHeaderField:@"Authorization"];

    [request setHTTPMethod:@"POST"];

    NSString *message = [NSString stringWithFormat:
                         @"%@\n"
                         "by @%@\n\n"
                         "```\n"
                         "[Category]\n%@\n\n"
                         "[Message]\n%@\n\n"
                         "[App Title]\n%@\n\n"
                         "[App Version]\n"
                         "Version: %@\n"
                         "Build: %@\n\n"
                         "[Device]\n"
                         "iOS: %@\n"
                         "Model: %@ (%@)\n"
                         , data.title, data.username, data.category, data.comment, data.appTitle, data.appVersion, data.appBuildVersion, data.systemVersion, data.modelName, data.modelCode];

    if (self.branchName) {
        message = [message stringByAppendingFormat:@"\n[Branch]\n%@\n", self.branchName];
    }
    message = [message stringByAppendingFormat:@"```\n"];
    
    //postデータ作成
    NSMutableData *feedbackData = [NSMutableData new];
    [self setTextData:feedbackData
       textDictionary:@{@"channels":self.channel,
                        @"initial_comment":message}
             boundary:boundary];
    [self setImageData:feedbackData imageData:data.imageData videoPath:data.videoPath boundary:boundary];
    
    [request setHTTPBody:feedbackData];
    
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
}

- (NSMutableData*)setTextData:(NSMutableData *)feedbackData textDictionary:(NSDictionary *)textDictionary boundary:(NSString *)boundary {
    for (id key in [textDictionary keyEnumerator]) {
        NSString* value = [textDictionary valueForKey:key];
        [feedbackData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [feedbackData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data;"] dataUsingEncoding:NSUTF8StringEncoding]];
        [feedbackData appendData:[[NSString stringWithFormat:@"name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [feedbackData appendData:[[NSString stringWithFormat:@"%@\r\n", value] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return feedbackData;
}

- (NSMutableData*)setImageData:(NSMutableData *)feedbackData imageData:(NSData *)imageData videoPath:(NSURL *)videoPath boundary:(NSString *)boundary {
    [feedbackData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [feedbackData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data;"] dataUsingEncoding:NSUTF8StringEncoding]];
    [feedbackData appendData:[[NSString stringWithFormat:@"name=\"%@\";", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
    [feedbackData appendData:[[NSString stringWithFormat:@"filename=\"%@\"\r\n", @"file"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (videoPath) {
        NSData *videoData = [NSData dataWithContentsOfURL:videoPath];
        [feedbackData appendData:[[NSString stringWithFormat:@"Content-Type: video/mp4\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [feedbackData appendData:videoData];
    } else {
        [feedbackData appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [feedbackData appendData:imageData];
    }
    
    [feedbackData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // last
    [feedbackData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return feedbackData;
}

@end
