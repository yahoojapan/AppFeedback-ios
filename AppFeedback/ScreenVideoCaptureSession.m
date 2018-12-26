//
//  ScreenVideoCaptureSession.m
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


#import "ScreenVideoCaptureSession.h"
#import "ScreenCapture.h"
#import "Logger.h"

@import AVFoundation;
@import UIKit;

@interface ScreenVideoCaptureSession ()

@property (atomic) BOOL recording;
@property (nonatomic, strong) NSDate *startedAt;
@property (nonatomic, strong) NSURL *outputFile;
@property (nonatomic) UIInterfaceOrientation initOrientation;
@property (nonatomic) CGSize initScreenSize;
@property (nonatomic) CGFloat initScreenScale;
@property (nonatomic, copy) StopRecordingCallBack callback;
@property (nonatomic, assign) float frameRate;
@property (nonatomic, strong) AVAssetWriter *videoWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *avAdaptor;
@property (nonatomic, strong) NSTimer *timer;

@end


@implementation ScreenVideoCaptureSession

- (id) init {
    self = [super init];
    if (self) {
        self.frameRate = 20.0f; // frames per seconds
    }
    return self;
}

- (float)interval {
    return 1.0 / self.frameRate;
}

- (void)cleanupWriter {
    _avAdaptor = nil;
    _videoWriterInput = nil;
    _videoWriter = nil;
}

- (void)dealloc {
    [self cleanupWriter];

    _outputFile = nil;
    _startedAt = nil;
}

- (NSURL*)tempFileURL:(NSString *)name {
    NSString* outputPath = [NSString pathWithComponents:@[NSTemporaryDirectory(), name]];
    return [[NSURL alloc] initFileURLWithPath:outputPath];
}

- (void)clearFile:(NSURL *)path {
    NSFileManager* fileManager = [NSFileManager defaultManager];

    NSError* error;

    if ([path checkResourceIsReachableAndReturnError:&error]) {
        if (![fileManager removeItemAtURL:path error:&error]) {
            Log(@"Could not delete old recording file at path:  %@", path.absoluteString);
        }
    }
}

-(BOOL) setUpWriter {
    self.outputFile = [self tempFileURL:@"app_feedback_video.mp4"];
    [self clearFile:self.outputFile];

    NSError* error = nil;
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:self.outputFile
                                                 fileType:AVFileTypeQuickTimeMovie
                                                    error:&error];
    NSParameterAssert(self.videoWriter);

    //Configure video
    NSDictionary* videoCompressionProps = @{
                                            // 明示的に設定しなくて良さそう
                                            //AVVideoAverageBitRateKey: @(1024.0*1024.0),
                                            //AVVideoMaxKeyFrameIntervalKey: @(self.frameRate),
                                            };

    CGSize imageSize = self.initScreenSize;
    CGFloat scale = self.initScreenScale;

    imageSize.height *= scale;
    imageSize.width *= scale;

    NSDictionary* videoSettings = @{
                                    AVVideoCodecKey: AVVideoCodecH264,
                                    AVVideoWidthKey: @(imageSize.width),
                                    AVVideoHeightKey: @(imageSize.height),
                                    AVVideoCompressionPropertiesKey: videoCompressionProps,
                                    };
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                          outputSettings:videoSettings];

    NSParameterAssert(self.videoWriterInput);
    self.videoWriterInput.expectsMediaDataInRealTime = YES;
    NSDictionary* bufferAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @(kCVPixelFormatType_32BGRA), kCVPixelBufferPixelFormatTypeKey,
                                      nil];
    
    self.avAdaptor = [AVAssetWriterInputPixelBufferAdaptor
                      assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoWriterInput
                      sourcePixelBufferAttributes:bufferAttributes];

    //add input
    [self.videoWriter addInput:self.videoWriterInput];
    [self.videoWriter startWriting];
    [self.videoWriter startSessionAtSourceTime:CMTimeMake(0, 1000)];

    return YES;
}

- (CGFloat)fixedImageScale {
    CGSize size = UIScreen.mainScreen.bounds.size;
    CGFloat scale = UIScreen.mainScreen.scale;
    if (size.width == 667 && size.height == 375 && scale == 2.0) {
        // iPhone 6, 7 などの4.7 インチ端末の横向きでなぜか動画が正常にキャプチャできないため
        // scale をいじる。この scale だとなぜかうまくいく (^^;
        return 1.5;
    } else if (size.width == 375 && size.height == 812 && scale == 3.0) {
        // iPhone X ポートレートモードでキャプチャを正常に取れるようにする対応
        return 2.0;
    } else if (size.width == 812 && size.height == 375 && scale == 3.0) {
        // iPhone X ランドスケープモードでキャプチャを正常に取れるようにする対応
        return 1.2;
    }
    return scale;
}

- (void)runRecordFrameLoop:(float)delay {
    if (!self.recording) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self completeRecordingSession];
        });
        return;
    }

    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC), q, ^{
        [self recordFrame];
    });
}

- (void) recordFrame {
    NSDate* start = [NSDate date];

    __block UIImage *image = nil;
    dispatch_sync(dispatch_get_main_queue(), ^{
        image = [ScreenCapture captureImageWithScale:self.initScreenScale
                                                size:self.initScreenSize
                                     baseOrientation:self.initOrientation];
    });

    float millisElapsed = [[NSDate date] timeIntervalSinceDate:self.startedAt] * 1000.0;
    [self writeVideoFrameAtTime:CMTimeMake((int)millisElapsed, 1000) image:image];

    float processingSeconds = [[NSDate date] timeIntervalSinceDate:start];
    float delayRemaining = [self interval] - processingSeconds;
    if (delayRemaining <= 0.0) {
        // Log(@"delayRemaining %.2f", delayRemaining);
    }

    float delay = delayRemaining > 0.0 ? delayRemaining : [self interval];
    [self runRecordFrameLoop:delay];
}

- (void) completeRecordingSession {
    // このメソッドはバックグラウンドで呼ばれる

    [self.videoWriterInput markAsFinished];

    // Wait for the video
    int status = self.videoWriter.status;
    while (status == AVAssetWriterStatusUnknown) {
        // Log(@"Waiting...");
        [NSThread sleepForTimeInterval:0.5f];
        status = self.videoWriter.status;
    }

    [self.videoWriter finishWritingWithCompletionHandler:^{
        AVAssetWriterStatus status = self.videoWriter.status;
        
        if (self.videoWriter.error) {
            NSError *error = self.videoWriter.error;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.callback(nil, error);
                self.callback = nil;
            });
        }
        else if (status == AVAssetWriterStatusCompleted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.callback(self.outputFile, nil);
                self.callback = nil;
            });
        }
        [self cleanupWriter];
    }];
}

- (bool)startRecordingUntil:(float)timeLimitSecs callback:(StopRecordingCallBack)callback {
    if (self.recording) {
        Log(@"Already recording.");
        return NO;
    }

    self.initOrientation = UIApplication.sharedApplication.statusBarOrientation;
    self.initScreenSize = UIScreen.mainScreen.bounds.size;;
    self.initScreenScale = [self fixedImageScale];

    if (![self setUpWriter]) {
        Log(@"setUpWriter failed.");
        return NO;
    }
    
    self.callback = callback;
    self.startedAt = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:timeLimitSecs
                                                  target:self
                                                selector:@selector(timerFired:)
                                                userInfo:nil
                                                 repeats:NO];
    self.recording = true;
    [self runRecordFrameLoop:0];

    return YES;
}

- (void)stopRecording {
    if (self.recording) {
        [self.timer invalidate];
        self.timer = nil;
        self.recording = false;
    }
}

- (void)timerFired:(NSTimer *)timer {
    [self stopRecording];
}

-(void) writeVideoFrameAtTime:(CMTime)time image:(UIImage *)image {
    if (![self.videoWriterInput isReadyForMoreMediaData]) {
        Log(@"videoWriterInput not ready for video data");
        return;
    }
    
    if (!self.avAdaptor.pixelBufferPool) {
        Log(@"Error pixelBufferPool is nil.");
        return;
    }

    CVPixelBufferRef pixelBuffer = NULL;
    int status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, self.avAdaptor.pixelBufferPool, &pixelBuffer);
    if(status != 0){
        //could not get a buffer from the pool
        Log(@"Error creating pixel buffer:  status=%d", status);
        return;
    }

    CGImageRef cgImage = CGImageCreateCopy([image CGImage]);
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider(cgImage));
    
    // set image data into pixel buffer
    CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
    uint8_t* destPixels = CVPixelBufferGetBaseAddress(pixelBuffer);
    CFRange range = CFRangeMake(0, CFDataGetLength(data));
    CFDataGetBytes(data, range, destPixels);
    
    BOOL appendSuccess = [self.avAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:time];

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVPixelBufferRelease(pixelBuffer);
    CFRelease(data);
    CGImageRelease(cgImage);

    if (!appendSuccess) {
        Log(@"appendPixelBuffer failed");
    }
}

@end
