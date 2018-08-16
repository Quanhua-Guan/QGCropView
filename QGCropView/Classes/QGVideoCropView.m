//
//  QGVideoCropView.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/30.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGVideoCropView.h"
#import "QGVideoRangePreviewView.h"
#import "AVAsset+QGCommon.h"
#import "QGMacro.h"
#import "QGVideoExporter.h"

@interface QGVideoCropView ()

@property (nonatomic, strong) QGVideoRangePreviewView *videoPreviewView;

@property (nonatomic, strong) QGVideoExporter *videoExporter;

@end

@implementation QGVideoCropView

#pragma mark - Setters

- (void)setOriginVideoAsset:(AVAsset *)originVideoAsset {
    _originVideoAsset = originVideoAsset;
    
    CGSize pixelSize = _originVideoAsset.qg_videoSize;
    self.contentPixelSize = pixelSize;
    
    _videoPreviewView = [QGVideoRangePreviewView new];
    _videoPreviewView.playerItem = [AVPlayerItem playerItemWithAsset:_originVideoAsset];
    [self resetContent:_videoPreviewView];
    [_videoPreviewView pause];
}

- (void)setCropTimeRange:(CMTimeRange)cropTimeRange {
    BOOL isPlaying = _videoPreviewView.isPlaying;
    [_videoPreviewView pause];
    
    CMTimeRange fullTimeRange = CMTimeRangeMake(kCMTimeZero, _originVideoAsset.duration);
    _cropTimeRange = CMTimeRangeGetIntersection(fullTimeRange, cropTimeRange);
    
    _videoPreviewView.playTimeRange = _cropTimeRange;
    
    if (isPlaying) {
        [_videoPreviewView play];
    }
}

#pragma mark - Play / Pause

- (void)play {
    [_videoPreviewView play];
}

- (void)pause {
    [_videoPreviewView pause];
}

#pragma mark - 裁剪&导出

- (void)cancelExport {
    [_videoExporter cancelExport];
}

- (void)exportVideoToPath:(NSString *)videoOutputPath
             preferredFPS:(CGFloat)preferredFPS
                 progress:(void(^_Nullable)(CGFloat progress))progress
                 canceled:(void (^_Nullable)(void))canceled
                 finished:(void(^_Nullable)(NSError *_Nullable error))finished {
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    CMTimeRange timeRange = _cropTimeRange;
    AVAsset *asset = _originVideoAsset;
    
    /* 音频轨道 */
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    if (videoTrack) {
        [videoCompositionTrack insertTimeRange:timeRange
                                       ofTrack:videoTrack
                                        atTime:kCMTimeZero
                                         error:nil];
    }
    
    /* 音频轨道 */
    for(AVAssetTrack *assetAudioTrack in [asset tracksWithMediaType:AVMediaTypeAudio]) {
        AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [audioCompositionTrack insertTimeRange:timeRange
                                       ofTrack:assetAudioTrack
                                        atTime:kCMTimeZero
                                         error:nil];
    }
    
    CMTimeRange cropVideoTimeRange = CMTimeRangeMake(kCMTimeZero, timeRange.duration);
    
    AVMutableVideoCompositionLayerInstruction *videoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstruction];
    videoCompositionLayerInstruction.trackID = videoCompositionTrack.trackID;
    
    /* 变换:旋转/缩放/平移 */
    
    /* 计算基础缩放值scale */
    CGRect bounds = CGRectZero;
    bounds.size = self.contentPixelSize;
    CGSize scaledCropPixelSize = AVMakeRectWithAspectRatioInsideRect(self.cropPixelSize, bounds).size;
    CGFloat scale = self.cropPixelSize.width / scaledCropPixelSize.width;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    /* 判断视频是否被逆时针旋转过90° */
    BOOL videoRotated = !CGAffineTransformEqualToTransform(videoTrack.preferredTransform, CGAffineTransformIdentity);
    
    /* 将原点移动到绘制区域中心点 */
    transform = CGAffineTransformTranslate(transform, self.cropPixelSize.width / 2, self.cropPixelSize.height / 2);
    
    /* 旋转, 当视频被逆时针旋转过90°时, 要顺时针旋转90°(转正) */
    CGFloat rotation = self.rotation + (videoRotated ? M_PI_2 : 0);
    transform = CGAffineTransformRotate(transform, rotation);
    /* 缩放 */
    transform = CGAffineTransformScale(transform, self.scale * scale, self.scale * scale);
    
    /* 将视频中心点移动到绘制区域中心点(即视频和绘制区域居中对齐) */
    CGSize videoNaturalSize = [videoTrack naturalSize];
    transform = CGAffineTransformTranslate(transform, -videoNaturalSize.width / 2, -videoNaturalSize.height / 2);
    
    /* 平移操作 */
    CGPoint translation = self.relativeTranslation;
    translation.x = translation.x * self.cropPixelSize.width;
    translation.y = translation.y * self.cropPixelSize.height;
    if (videoRotated) {
        /* 之前的操作进行了额外顺时针90°旋转, 所以移动值需要进行逆时针90°旋转, 以抵消影响 */
        translation = CGPointApplyAffineTransform(translation, CGAffineTransformMakeRotation(-M_PI_2));
    }
    /* 之前的操作进行了额外scale的缩放, 需要进行1.0 / scale的方向缩放, 以抵消影响 */
    translation = CGPointApplyAffineTransform(translation, CGAffineTransformMakeScale(1.0f / scale, 1.0f / scale));
    
    transform = CGAffineTransformTranslate(transform, translation.x, translation.y);
    
    /* 设置包含旋转/缩放/平移的变换 */
    if (!CGAffineTransformIsIdentity(transform)) {
        [videoCompositionLayerInstruction setTransform:transform atTime:kCMTimeZero];
    }
    
    /* AVMutableVideoCompositionInstruction */
    AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoCompositionInstruction.timeRange = cropVideoTimeRange;
    videoCompositionInstruction.layerInstructions = @[videoCompositionLayerInstruction];
    
    /* AVMutableVideoComposition */
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = [NSArray arrayWithObject:videoCompositionInstruction];
    videoComposition.frameDuration = CMTimeMake(1, preferredFPS > 0 ? preferredFPS : 30);
    videoComposition.renderSize = self.cropPixelSize;
    videoComposition.renderScale = 1.0;
    
    /* 导出 */
    NSParameterAssert(composition);
    NSParameterAssert(videoComposition);
    
    _videoExporter = [[QGVideoExporter alloc] initWithAsset:composition audioMix:nil videoComposition:videoComposition];
    [_videoExporter exportVideoToPath:videoOutputPath progress:progress canceled:canceled finished:finished];
}

@end

