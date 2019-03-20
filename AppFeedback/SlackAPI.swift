//
//  SlackAPI.swift
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

@objcMembers
public class SlackAPI: NSObject {
    private let token: String
    private let channel: String
    private let apiUrl: String
    private let branchName: String?
    
    static public let boundary = "AppFeedbackiOSSDKBoundary"
    
    public init(token: String,
                channel: String,
                apiUrl: String,
                branchName: String?) {
        self.token = token
        self.channel = channel
        self.apiUrl = apiUrl
        self.branchName = branchName
    }
    
    public func post(data: SendData, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let urlString = apiUrl + "/files.upload"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.setValue("multipart/form-data; boundary=\(SlackAPI.boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let message = data.convertToMessage(with: branchName)
        var feedbackData = Data()
        let textDictionary = ["channels": channel, "initial_comment": message]
        feedbackData.setTextData(textDictionary: textDictionary)
        feedbackData.setImageData(data.imageData, videoPath: data.videoPath)
        
        request.httpBody = feedbackData
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
}

fileprivate extension Data {
    mutating func setTextData(textDictionary: Dictionary<String, String>) {
        textDictionary.forEach { key, value in
            appendBoundary()
            append(contentDisposition: "form-data;")
            append(name: key)
            append(value: value)
        }
    }
    
    mutating func setImageData(_ imageData: Data?, videoPath: URL?) {
        appendBoundary()
        append(contentDisposition: "form-data;")
        appendData(string: "name=\"file\";")
        
        if let videoPath = videoPath {
            guard let videoData = try? Data.init(contentsOf: videoPath) else { return }
            append(fileName: "ScreenCapture.mp4")
            append(contentType: "video/mp4")
            append(videoData)
        } else {
            guard let imageData = imageData else { return }
            append(fileName: "ScreenCapture.png")
            append(contentType: "image/jpeg")
            append(imageData)
        }
        appendData(string: "\r\n")
        appendEndingBoundary()
    }
    
    private mutating func appendBoundary() {
        appendData(string: "--\(SlackAPI.boundary)\r\n")
    }
    
    private mutating func appendEndingBoundary() {
        appendData(string: "--\(SlackAPI.boundary)--\r\n")
    }
    
    private mutating func append(contentDisposition: String) {
        appendData(string: "Content-Disposition: \(contentDisposition)")
    }
    
    private mutating func append(contentType: String) {
        appendData(string: "Content-Type: \(contentType)\r\n\r\n")
    }
    
    private mutating func append(fileName: String) {
        appendData(string: "filename=\"\(fileName)\"\r\n")
    }
    
    private mutating func append(name: String) {
        appendData(string: "name=\"\(name)\"\r\n\r\n")
    }
    
    private mutating func append(value: String) {
        appendData(string: "\(value)\r\n")
    }
    
    private mutating func appendData(string: String) {
        guard let data = string.data(using: .utf8) else { return }
        append(data)
    }
}



