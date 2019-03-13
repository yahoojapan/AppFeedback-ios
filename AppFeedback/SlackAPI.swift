//
//  SlackAPI.swift
//  AppFeedback
//
//  Created by Shota Nakagami on 2019/03/13.
//  Copyright © 2019 Yahoo! JAPAN Corporation. All rights reserved.
//

import Foundation

@objcMembers
public class SlackAPI: NSObject {
    private let token: String
    private let channel: String
    private let apiUrl: String
    private let branchName: String
    
    static public let boundary = "AppFeedbackiOSSDKBoundary"
    
    public init(token: String,
                channel: String,
                apiUrl: String,
                branchName: String) {
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
        
        let message = makeMessage(from: data)
            .appendingFormat("\n[Branch]\n%s\n", branchName)
            .appending("```\n")
        
        var feedbackData = Data()
        let textDictionary = ["channels": channel, "initial_comment": message]
        feedbackData.setTextData(textDictionary: textDictionary)
        feedbackData.setImageData(data.imageData, videoPath: data.videoPath)
        
        request.httpBody = feedbackData
        
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: .main)
        let task = session.dataTask(with: request, completionHandler: completionHandler)
        task.resume()
    }
    
    private func makeMessage(from data: SendData) -> String {
        let unknown = "-"
        return """
        "\(data.title ?? unknown)"
        "by @\(data.username ?? unknown)\n"
        "```"
        "[Category]\n\(data.category ?? unknown)\n"
        "[Message]\n\(data.comment ?? unknown)\n"
        "[App Title]\n\(data.appTitle ?? unknown)\n"
        "[App Version]"
        "Version: \(data.appVersion ?? unknown)"
        "Build: \(data.appBuildVersion ?? unknown)\n"
        "[Device]"
        "iOS: \(data.systemVersion ?? unknown)"
        "Model: \(data.modelName ?? unknown) (\(data.modelCode ?? unknown))"
        """
    }
}

fileprivate extension Data {
    mutating func setTextData(textDictionary: Dictionary<String, String>) {
        textDictionary.forEach { key, value in
            appendBoundary()
            appendContentDisposition()
            append(name: key)
            append(value: value)
        }
    }
    
    mutating func setImageData(_ imageData: Data?, videoPath: URL?) {
        appendBoundary()
        appendContentDisposition()
        appendData(string: "name=\"file\"")
        
        if let videoPath = videoPath {
            guard let videoData = try? Data.init(contentsOf: videoPath) else { return }
            appendData(string: "filename=\"ScreenCapture.mp4\"\r\n")
            appendData(string: "Content-Type: video/mp4\r\n\r\n")
            append(videoData)
        } else {
            guard let imageData = imageData else { return }
            appendData(string: "filename=\"ScreenCapture.png\"\r\n")
            appendData(string: "Content-Type: image/jpeg\r\n\r\n")
            append(imageData)
        }
        appendData(string: "\r\n")
        appendBoundary()
    }

    private mutating func appendBoundary() {
        appendData(string: "--\(SlackAPI.boundary)\r\n")
    }
    
    private mutating func appendContentDisposition() {
        appendData(string: "Content-Disposition: form-data;")
    }
    
    private mutating func append(name: String) {
        appendData(string: "name=\"\(name)\"\r\n\r\n")
    }
    
    private mutating func append(value: String) {
        appendData(string: "\(value)\"\r\n")
    }
    
    private mutating func appendData(string: String) {
        guard let data = string.data(using: .utf8) else { return }
        append(data)
    }
}


