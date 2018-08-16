//
//  QGVideoExporter.m
//  AFNetworking
//
//  Created by 宇园 on 2018/4/12.
//

#import "QGVideoExporter.h"
#import <AVFoundation/AVFoundation.h>
#import "QGMacro.h"

@interface QGVideoExporter ()

@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVAudioMix *audioMix;
@property (nonatomic, strong) AVVideoComposition *videoComposition;

@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) NSTimer *exportTimer;

@end

@implementation QGVideoExporter

#pragma mark - Init

- (instancetype)initWithAsset:(AVAsset *)asset audioMix:(AVAudioMix *_Nullable)audioMix videoComposition:(AVVideoComposition *_Nullable)videoComposition {
    self = [super init];
    if (self) {
        _asset = asset;
        _audioMix = audioMix;
        _videoComposition = videoComposition;
    }
    
    return self;
}

#pragma mark - 导出

- (void)cancelExport {
    NSParameterAssert(_exportSession);
    
    [_exportSession cancelExport];
}

- (void)exportVideoToPath:(NSString *)videoOutputPath
                 progress:(void(^_Nullable)(CGFloat progress))progress
                 canceled:(void (^_Nullable)(void))canceled
                 finished:(void(^_Nullable)(NSError *error))finished {
    NSParameterAssert(_asset);
    NSAssert(_exportSession == nil, @"一个合成器同一时刻只能存在一个导出操作!");
    
    if ([NSFileManager.defaultManager fileExistsAtPath:videoOutputPath]) {
        [NSFileManager.defaultManager removeItemAtPath:videoOutputPath error:nil];
    }
    
    _exportSession = [AVAssetExportSession exportSessionWithAsset:_asset presetName:AVAssetExportPresetHighestQuality];
    _exportSession.videoComposition = _videoComposition;
    _exportSession.audioMix = _audioMix;
    _exportSession.outputURL = [NSURL fileURLWithPath:videoOutputPath];
    _exportSession.outputFileType = AVFileTypeMPEG4;
    _exportSession.shouldOptimizeForNetworkUse = YES;
    
    @weakify(self);
    [_exportSession exportAsynchronouslyWithCompletionHandler:^{
        @strongify(self);
        
        /* 关闭计时器, 回调进度1.0 */
        [self invalidateExportTimer];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progress) {
                progress(1.0f);
            }
        });
        
        NSError *error = self.exportSession.error;
        switch (self.exportSession.status) {
                /* 未知异常, 视为合成失败 */
            case AVAssetExportSessionStatusUnknown: {
                if (!error) {
                    error = [NSError errorWithDomain:@"com.sdk.QGCropView" code:9999 userInfo:@{NSLocalizedDescriptionKey : @"未知错误!"}];
                }
                // fall through (发生未知错误时,视为合成失败)
            }
                /* 导出失败/成功 */
            case AVAssetExportSessionStatusFailed:
            case AVAssetExportSessionStatusCompleted: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (finished) {
                            finished(error);
                        }
                    });
                    self.exportSession = nil;// 移除导出Session
                });
                break;
            }
                /* 导出被取消 */
            case AVAssetExportSessionStatusCancelled: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (canceled) {
                            canceled();
                        }
                    });
                    self.exportSession = nil;// 移除导出Session
                });
                break;
            }
            case AVAssetExportSessionStatusExporting:
            case AVAssetExportSessionStatusWaiting:
            default: {
                break;
            }
        }
    }];
    
    _exportTimer = [NSTimer timerWithTimeInterval:0.2f target:self selector:@selector(exportTimerHandler:) userInfo:[progress copy] repeats:YES];
    [NSRunLoop.currentRunLoop addTimer:_exportTimer forMode:NSRunLoopCommonModes];
    [_exportTimer fire];
}

#pragma mark - 导出计时器回调

- (void)exportTimerHandler:(NSTimer *)timer {
    if (self.exportSession == nil) {
        [self invalidateExportTimer];
    } else {
        if ([timer userInfo]) {
            void (^progressBlock)(CGFloat progress) = (void (^)(CGFloat progress))[timer userInfo];
            progressBlock(self.exportSession.progress);
            
            if (self.exportSession.progress >= 1.0f) {
                [self invalidateExportTimer];
            }
        }
    }
}

- (void)invalidateExportTimer {
    [self.exportTimer invalidate];
    self.exportTimer = nil;
}

@end
