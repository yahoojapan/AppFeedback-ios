//
//  DeviceUtil.swift
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

import Foundation

@objc public class DeviceUtil: NSObject {
    @objc public static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    
    @objc public static var appBuildVersion: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
    
    @objc public static var osName: String {
        return UIDevice.current.systemName
    }
    
    @objc public static var osVersion: String {
        return UIDevice.current.systemVersion
    }
    
    @objc public static var modelCode: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    @objc public static var modelName: String {
        switch modelCode {
            case "i386": return "Simulator"
            case "x86_64": return "Simulator"
            
            case "iPod1,1": return "iPod Touch 1st"
            case "iPod2,1": return "iPod Touch 2nd"
            case "iPod3,1": return "iPod Touch 3rd"
            case "iPod4,1": return "iPod Touch 4th"
            case "iPod5,1": return "iPod Touch 5th"
            case "iPod7,1": return "iPod Touch 6th"
            
            case "iPhone1,1": return "iPhone"
            case "iPhone1,2": return "iPhone"
            case "iPhone2,1": return "iPhone"
            case "iPhone3,1": return "iPhone 4"
            case "iPhone3,2": return "iPhone 4"
            case "iPhone3,3": return "iPhone 4"
            case "iPhone4,1": return "iPhone 4S"
            case "iPhone5,1": return "iPhone 5"
            case "iPhone5,2": return "iPhone 5"
            case "iPhone5,3": return "iPhone 5c"
            case "iPhone5,4": return "iPhone 5c"
            case "iPhone6,1": return "iPhone 5s"
            case "iPhone6,2": return "iPhone 5s"
            case "iPhone7,1": return "iPhone 6 Plus"
            case "iPhone7,2": return "iPhone 6"
            case "iPhone8,1": return "iPhone 6S"
            case "iPhone8,2": return "iPhone 6S Plus"
            case "iPhone8,4": return "iPhone SE"
            case "iPhone9,1": return "iPhone 7"
            case "iPhone9,3": return "iPhone 7"
            case "iPhone9,2": return "iPhone 7 Plus"
            case "iPhone9,4": return "iPhone 7 Plus"
            case "iPhone10,1": return "iPhone 8"
            case "iPhone10,4": return "iPhone 8"
            case "iPhone10,2": return "iPhone 8 Plus"
            case "iPhone10,5": return "iPhone 8 Plus"
            case "iPhone10,3": return "iPhone X"
            case "iPhone10,6": return "iPhone X"
            case "iPhone11,8": return "iPhone XR"
            case "iPhone11,2": return "iPhone XS"
            case "iPhone11,4": return "iPhone XS Max"
            case "iPhone11,6": return "iPhone XS Max"
            
            case "iPad1,1": return "iPad 1 "
            case "iPad2,1": return "iPad 2 WiFi"
            case "iPad2,2": return "iPad 2 Cellular"
            case "iPad2,3": return "iPad 2 Cellular"
            case "iPad2,4": return "iPad 2 WiFi"
            case "iPad2,5": return "iPad Mini WiFi"
            case "iPad2,6": return "iPad Mini Cellular"
            case "iPad2,7": return "iPad Mini Cellular"
            case "iPad3,1": return "iPad 3 WiFi"
            case "iPad3,2": return "iPad 3 Cellular"
            case "iPad3,3": return "iPad 3 Cellular"
            case "iPad3,4": return "iPad 4 WiFi"
            case "iPad3,5": return "iPad 4 Cellular"
            case "iPad3,6": return "iPad 4 Cellular"
            case "iPad4,1": return "iPad Air WiFi"
            case "iPad4,2": return "iPad Air Cellular"
            case "iPad4,3": return "iPad Air China"
            case "iPad4,4": return "iPad Mini 2 WiFi"
            case "iPad4,5": return "iPad Mini 2 Cellular"
            case "iPad4,6": return "iPad Mini 2 China"
            case "iPad4,7": return "iPad Mini 3 WiFi"
            case "iPad4,8": return "iPad Mini 3 Cellular"
            case "iPad4,9": return "iPad Mini 3 China"
            case "iPad5,1": return "iPad Mini 4 WiFi"
            case "iPad5,2": return "iPad Mini 4 Cellular"
            case "iPad5,3": return "iPad Air 2 WiFi"
            case "iPad5,4": return "iPad Air 2 Cellular"
            case "iPad6,3": return "iPad Pro 9.7inch WiFi"
            case "iPad6,4": return "iPad Pro 9.7inch Cellular"
            case "iPad6,7": return "iPad Pro 12.9inch WiFi"
            case "iPad6,8": return "iPad Pro 12.9inch Cellular"
            case "iPad6,11": return "iPad 5th WiFi"
            case "iPad6,12": return "iPad 5th Cellular"
            case "iPad7,1": return "iPad Pro 12.9inch 2nd WiFi"
            case "iPad7,2": return "iPad Pro 12.9inch 2nd Cellular"
            case "iPad7,3": return "iPad Pro 10.5inch WiFi"
            case "iPad7,4": return "iPad Pro 10.5inch Cellular"
            case "iPad7,5": return "iPad 6th WiFi"
            case "iPad7,6": return "iPad 6th Cellular"
        default:
            return ""
        }
    }
}
