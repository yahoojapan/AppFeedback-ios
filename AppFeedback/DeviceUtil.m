//
//  DeviceUtil.m
//  DeviceUtil
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
#import "DeviceUtil.h"
#import <sys/utsname.h>
#import <AppFeedback/AppFeedback-Swift.h>

@class StringUtil;
//@implementation DeviceUtil
//+ (NSString *)appVersion {
//    return NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
//}
//
//+ (NSString *)appBuildVersion {
//    return NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"];
//}
//
//+ (NSString *)OSName {
//    return UIDevice.currentDevice.systemName;
//}
//
//+ (NSString *)OSVersion {
//    return UIDevice.currentDevice.systemVersion;
//}
//
//+ (NSString *)ModelCode {
//    struct utsname systemInfo;
//    uname(&systemInfo);
//
//    return [NSString stringWithCString:systemInfo.machine
//                              encoding:NSUTF8StringEncoding];
//}
//
//+ (NSString *)ModelName {
//    NSString *modelCode = DeviceUtil.ModelCode;
//    NSDictionary<NSString*, NSString*>* deviceNames = @{
//                          @"i386"       :@"Simulator",
//                          @"x86_64"     :@"Simulator",
//
//                          @"iPod1,1"    :@"iPod Touch 1st",
//                          @"iPod2,1"    :@"iPod Touch 2nd",
//                          @"iPod3,1"    :@"iPod Touch 3rd",
//                          @"iPod4,1"    :@"iPod Touch 4th",
//                          @"iPod5,1"    :@"iPod Touch 5th",
//                          @"iPod7,1"    :@"iPod Touch 6th",
//
//                          @"iPhone1,1"  :@"iPhone",
//                          @"iPhone1,2"  :@"iPhone",
//                          @"iPhone2,1"  :@"iPhone",
//                          @"iPhone3,1"  :@"iPhone 4",
//                          @"iPhone3,2"  :@"iPhone 4",
//                          @"iPhone3,3"  :@"iPhone 4",
//                          @"iPhone4,1"  :@"iPhone 4S",
//                          @"iPhone5,1"  :@"iPhone 5",
//                          @"iPhone5,2"  :@"iPhone 5",
//                          @"iPhone5,3"  :@"iPhone 5c",
//                          @"iPhone5,4"  :@"iPhone 5c",
//                          @"iPhone6,1"  :@"iPhone 5s",
//                          @"iPhone6,2"  :@"iPhone 5s",
//                          @"iPhone7,1"  :@"iPhone 6 Plus",
//                          @"iPhone7,2"  :@"iPhone 6",
//                          @"iPhone8,1"  :@"iPhone 6S",
//                          @"iPhone8,2"  :@"iPhone 6S Plus",
//                          @"iPhone8,4"  :@"iPhone SE",
//                          @"iPhone9,1"  :@"iPhone 7",
//                          @"iPhone9,3"  :@"iPhone 7",
//                          @"iPhone9,2"  :@"iPhone 7 Plus",
//                          @"iPhone9,4"  :@"iPhone 7 Plus",
//                          @"iPhone10,1" :@"iPhone 8",
//                          @"iPhone10,4" :@"iPhone 8",
//                          @"iPhone10,2" :@"iPhone 8 Plus",
//                          @"iPhone10,5" :@"iPhone 8 Plus",
//                          @"iPhone10,3" :@"iPhone X",
//                          @"iPhone10,6" :@"iPhone X",
//                          @"iPhone11,8" :@"iPhone XR",
//                          @"iPhone11,2" :@"iPhone XS",
//                          @"iPhone11,4" :@"iPhone XS Max",
//                          @"iPhone11,6" :@"iPhone XS Max",
//
//                          @"iPad1,1"   :@"iPad 1 ",
//                          @"iPad2,1"   :@"iPad 2 WiFi",
//                          @"iPad2,2"   :@"iPad 2 Cellular",
//                          @"iPad2,3"   :@"iPad 2 Cellular",
//                          @"iPad2,4"   :@"iPad 2 WiFi",
//                          @"iPad2,5"   :@"iPad Mini WiFi",
//                          @"iPad2,6"   :@"iPad Mini Cellular",
//                          @"iPad2,7"   :@"iPad Mini Cellular",
//                          @"iPad3,1"   :@"iPad 3 WiFi",
//                          @"iPad3,2"   :@"iPad 3 Cellular",
//                          @"iPad3,3"   :@"iPad 3 Cellular",
//                          @"iPad3,4"   :@"iPad 4 WiFi",
//                          @"iPad3,5"   :@"iPad 4 Cellular",
//                          @"iPad3,6"   :@"iPad 4 Cellular",
//                          @"iPad4,1"   :@"iPad Air WiFi",
//                          @"iPad4,2"   :@"iPad Air Cellular",
//                          @"iPad4,3"   :@"iPad Air China",
//                          @"iPad4,4"   :@"iPad Mini 2 WiFi",
//                          @"iPad4,5"   :@"iPad Mini 2 Cellular",
//                          @"iPad4,6"   :@"iPad Mini 2 China",
//                          @"iPad4,7"   :@"iPad Mini 3 WiFi",
//                          @"iPad4,8"   :@"iPad Mini 3 Cellular",
//                          @"iPad4,9"   :@"iPad Mini 3 China",
//                          @"iPad5,1"   :@"iPad Mini 4 WiFi",
//                          @"iPad5,2"   :@"iPad Mini 4 Cellular",
//                          @"iPad5,3"   :@"iPad Air 2 WiFi",
//                          @"iPad5,4"   :@"iPad Air 2 Cellular",
//                          @"iPad6,3"   :@"iPad Pro 9.7inch WiFi",
//                          @"iPad6,4"   :@"iPad Pro 9.7inch Cellular",
//                          @"iPad6,7"   :@"iPad Pro 12.9inch WiFi",
//                          @"iPad6,8"   :@"iPad Pro 12.9inch Cellular",
//                          @"iPad6,11"  :@"iPad 5th WiFi",
//                          @"iPad6,12"  :@"iPad 5th Cellular",
//                          @"iPad7,1"   :@"iPad Pro 12.9inch 2nd WiFi",
//                          @"iPad7,2"   :@"iPad Pro 12.9inch 2nd Cellular",
//                          @"iPad7,3"   :@"iPad Pro 10.5inch WiFi",
//                          @"iPad7,4"   :@"iPad Pro 10.5inch Cellular",
//                          @"iPad7,5"   :@"iPad 6th WiFi",
//                          @"iPad7,6"   :@"iPad 6th Cellular"
//                          };
//    return deviceNames[modelCode];
//}
//
//@end


@implementation StringUtil
+ (NSArray *)match:(NSRegularExpression *)regexp string:(NSString *)string {
    if (!regexp || !string || string.length <= 0)
        return nil;
    
    NSArray *matches = [regexp matchesInString:string
                                       options:0
                                         range:NSMakeRange(0, string.length)];
    if (!matches || matches.count < 1)
        return nil;
    
    NSTextCheckingResult *match = matches[0];
    NSMutableArray *array = [NSMutableArray array];
    for (NSUInteger i = 1; i < match.numberOfRanges; ++i) {
        NSRange range = [match rangeAtIndex:i];
        if (range.length <= 0) continue;
        
        [array addObject:[string substringWithRange:range]];
    }
    return array;
}

+ (NSArray *)matchPattern:(NSString *)pattern string:(NSString *)string {
    return [self matchPattern:pattern string:string ignoreCase:NO];
}

+ (NSArray *)matchPattern:(NSString *)pattern
                   string:(NSString *)string
               ignoreCase:(BOOL)ignoreCase {
    
    return [self match:[self makeRegularExpression:pattern
                                        ignoreCase:ignoreCase]
                string:string];
}
+ (NSRegularExpression *)makeRegularExpression:(NSString *)pattern
                                    ignoreCase:(BOOL)ignoreCase {
    
    if (!pattern || pattern.length <= 0)
        return nil;
    
    NSRegularExpressionOptions options =
    ignoreCase ? NSRegularExpressionCaseInsensitive : 0;
    NSError *e = nil;
    NSRegularExpression *regexp =
    [NSRegularExpression regularExpressionWithPattern:pattern
                                              options:options
                                                error:&e];
    return regexp && !e ? regexp : nil;
}
@end
