//
//  ScreenVideoCaptureSession.swift
//  ScreenVideoCaptureSession
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
import AVKit

@objcMembers
class ScreenVideoCaptureSession: NSObject {
    typealias StopRecordingCallBack = (URL, NSError) -> Void
    
    private let frameRate: Float = 20

    private(set) var recording: Bool = false
    
    private var startedAt: Date?
    private var outputFile: URL?
    private var initOrientation: UIInterfaceOrientation?
    private var initScreenSize: CGSize = .zero
    private var initScreenScale: CGFloat = 0
    private var callback: StopRecordingCallBack?
    private var videoWriter: AVAssetWriter?
    private var videoWriterInput: AVAssetWriterInput?
    private var avAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var timer: Timer?
    
    override init() {
        super.init()
    }
    
    private var interval: Float {
        return 1 / frameRate
    }
    
    private func cleanupWriter() {
        avAdaptor = nil
        videoWriterInput = nil
        videoWriter = nil
    }
    
    deinit {
        cleanupWriter()
        outputFile = nil
        startedAt = nil
    }
    
    private func tempFileURL(_ name: String) -> URL? {
        let outputPath = NSString.path(withComponents: [NSTemporaryDirectory(), name])
        return URL(fileURLWithPath: outputPath)
    }
    
    private func clearFile(path: URL) {
        let fileManager = FileManager.default
        do {
            if try path.checkResourceIsReachable() {
                try fileManager.removeItem(at: path)
            }
        } catch {
            print("Could not delete old recording file at path: \(path.absoluteString)")
        }
    }
    
    private func setupWriter() -> Bool {
        guard let outputFile = tempFileURL("app_feedback_video.mp4") else {
            return false
        }
        
        clearFile(path: outputFile)
        self.outputFile = outputFile
        
        do {
            videoWriter = try AVAssetWriter(outputURL: outputFile, fileType: .mov)
            var imageSize = initScreenSize
            let scale = initScreenScale
            
            imageSize.height *= scale
            imageSize.width *= scale
            
            let videSettings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecH264,
                AVVideoWidthKey: imageSize.width,
                AVVideoHeightKey: imageSize.height,
                AVVideoCompressionPropertiesKey: [String: Any]()
            ]
            
            let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videSettings)
            videoWriterInput.expectsMediaDataInRealTime = true
            let bufferAttributes: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            avAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: bufferAttributes)
            self.videoWriterInput = videoWriterInput
            
            
            videoWriter?.add(videoWriterInput)
            videoWriter?.startWriting()
            videoWriter?.startSession(atSourceTime: CMTime(value: 0, timescale: 1000))
        } catch {
        }
        
        return true
    }
    
    var fixedImageScale: CGFloat {
        let size = UIScreen.main.bounds.size
        let scale = UIScreen.main.scale
        
        if size.width == 667 && size.height == 375 && scale == 2.0 {
            return 1.5
        } else if size.width == 375 && size.height == 812 && scale == 3.0  {
            return 2.0
        } else if size.width == 812 && size.height == 375 && scale == 3.0 {
            return 1.2
        } else {
            return scale
        }
    }
    
    func runRecordFrameLoop(delay: Float) {
        if recording {
            
        }
    }
    
    
    func startRecordingUntil(_ tileLimitScs: Float, callback: StopRecordingCallBack) {
        
    }
    
    func stopRecording() {
        
    }
}
