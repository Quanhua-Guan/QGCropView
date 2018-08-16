//
//  QGAVideoNAudioCompositer.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/21.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGAVideoNAudioComposer.h"
#import "AVAsset+QGAVideoNAudioPreviewView.h"
#import "QGChangeFrameVideoCompositionInstruction.h"
#import "QGChangeFrameCompositer.h"
#import "QGMacro.h"
#import "QGVideoExporter.h"

@interface QGAVideoNAudioComposer ()

@property (nonatomic, strong) AVComposition *composition;
@property (nonatomic, strong) AVAudioMix *audioMix;
@property (nonatomic, strong) AVVideoComposition *videoComposition;

@property (nonatomic, strong) AVAsset *videoAsset;
@property (nonatomic, strong) NSArray<AVAsset *> *audioAssets;

@property (nonatomic, strong) QGVideoExporter *videoExporter;

@property (nonatomic, strong) CIImage *coverCIImage;
@property (nonatomic, strong) CIImage *watermarkCIImage;

@end

@implementation QGAVideoNAudioComposer

- (instancetype)initWithVideoAsset:(AVAsset *)videoAsset audioAssets:(NSArray<AVAsset *> *)audioAssets {
    NSParameterAssert(videoAsset);
    NSParameterAssert(audioAssets);
    
    self = [super init];
    if (self) {
        _videoAsset = videoAsset;
        _audioAssets = audioAssets;
        [self setup];
    }
    
    return self;
}

- (void)setup {
    AVAssetTrack *videoTrack = [_videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    NSAssert(videoTrack, @"视频轨道不能为空!");
    
    // 视频大小
    CGSize naturalSize = CGSizeApplyAffineTransform(videoTrack.naturalSize, videoTrack.preferredTransform);
    naturalSize = CGSizeMake(fabs(naturalSize.width), fabs(naturalSize.height));
    
    // 视频时间范围限制(设置默认值)
    if (CMTIME_COMPARE_INLINE(_videoAsset.qg_timeRangeUsedToComposite.duration, ==, kCMTimeZero)) {
        _videoAsset.qg_timeRangeUsedToComposite = videoTrack.timeRange;
    }
    if (CMTIME_COMPARE_INLINE(_videoAsset.qg_startTimeInCompositedVideo, !=, kCMTimeZero)) {
        _videoAsset.qg_startTimeInCompositedVideo = kCMTimeZero;
    }
    
    // 视频总时长
    CMTime duration = _videoAsset.qg_timeRangeUsedToComposite.duration;
    
    // 参数检查
    [self testAsset:_videoAsset videoDuration:duration type:AVMediaTypeVideo];
    
    // AVMutableComposition
    AVMutableComposition *composition = [AVMutableComposition composition];
    composition.naturalSize = naturalSize;
    
    // video track
    NSError *error = nil;
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:_videoAsset.qg_timeRangeUsedToComposite
                                   ofTrack:videoTrack
                                    atTime:_videoAsset.qg_startTimeInCompositedVideo
                                     error:&error];
    _videoAsset.qg_compositionTracks = @[videoCompositionTrack];
    
    // audio tracks
    for (AVAsset *audioAsset in _audioAssets) {
        NSArray<AVAssetTrack *> *audioTracks = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
        if (audioTracks.count == 0) {
            continue;
        }
        
        /* 在合成视频中的开始播放位置需要合法 */
        if (!CMTimeRangeContainsTime(CMTimeRangeMake(kCMTimeZero, duration), audioAsset.qg_startTimeInCompositedVideo)) {
            continue;
        }
        /* 播放时长需要大于0 */
        if (CMTIME_COMPARE_INLINE(audioAsset.qg_timeRangeUsedToComposite.duration, <=, kCMTimeZero)) {
            continue;
        }
        /* 用于播放的时间范围必须合法! */
        CMTimeRange audioAssetTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
        audioAsset.qg_timeRangeUsedToComposite = CMTimeRangeGetIntersection(audioAssetTimeRange, audioAsset.qg_timeRangeUsedToComposite);
        if (!CMTimeRangeContainsTimeRange(audioAssetTimeRange, audioAsset.qg_timeRangeUsedToComposite)) {
            continue;
        }
        
        NSMutableArray<AVCompositionTrack *> *compositionTracks = [NSMutableArray arrayWithCapacity:audioTracks.count];
        for (AVAssetTrack *audioTrack in audioTracks) {
            /* 以audioAsset时长为参考, 获得音轨的起始-结束之间 */
            CMTime audioStartTime = CMTimeMaximum(audioTrack.timeRange.start, audioAsset.qg_timeRangeUsedToComposite.start);
            CMTime audioEndTime = CMTimeMinimum(CMTimeRangeGetEnd(audioTrack.timeRange), CMTimeRangeGetEnd(audioAsset.qg_timeRangeUsedToComposite));
            if (CMTIME_COMPARE_INLINE(audioStartTime, >=, audioEndTime)) {
                continue;
            }
            CMTime audioDuration = CMTimeSubtract(audioEndTime, audioStartTime);
            
            /* 最终合成的整个视频中(以composition为参考), 插入音频的开始时间点 */
            CMTime insertStartTime = audioAsset.qg_startTimeInCompositedVideo;
            if (CMTIME_COMPARE_INLINE(audioStartTime, ==, audioTrack.timeRange.start)) {
                CMTime delta = CMTimeSubtract(audioTrack.timeRange.start, audioAsset.qg_timeRangeUsedToComposite.start);
                insertStartTime = CMTimeAdd(insertStartTime, delta);
            }
            /* 音频可能的最大时长 */
            CMTime maxAudioDuration = CMTimeSubtract(duration, insertStartTime);
            
            /* 转换成以audioTrack为参考的时间范围 */
            audioStartTime = CMTimeSubtract(audioStartTime, audioTrack.timeRange.start);
            CMTimeRange audioTimeRange = CMTimeRangeMake(audioStartTime, CMTimeMinimum(audioDuration, maxAudioDuration));
            
            AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                                        preferredTrackID:kCMPersistentTrackID_Invalid];
            [audioCompositionTrack insertTimeRange:audioTimeRange
                                           ofTrack:audioTrack
                                            atTime:insertStartTime
                                             error:&error];
            
            [compositionTracks addObject:audioCompositionTrack];
            
            if (error) {
                break;
            }
        }
        audioAsset.qg_compositionTracks = compositionTracks.copy;
        
        if (error) {
            break;
        }
    }
    
    if (error) {
        NSLog(@"Error: %@", error);
        NSAssert(NO, error.description);
    }
    
    // AVMutableVideoComposition
    AVMutableVideoComposition *videoComposition = nil;
    if (@available(iOS 10.0, *)) {
        @weakify(self);

        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        CIContext *renderingContext = [CIContext contextWithEAGLContext:eaglContext];
        videoComposition = [AVMutableVideoComposition videoCompositionWithAsset:composition applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
            @strongify(self);
            
            CIImage *image = nil;
            if (self.coverCIImage && CMTIME_COMPARE_INLINE(request.compositionTime, ==, kCMTimeZero)) {
                image = self.coverCIImage;
            } else {
                image = request.sourceImage;
            }
            
            if (self.watermarkImage) {
                /* 添加水印 */
                CIFilter *watermarkFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
                CIImage *backgroundImage = image;
                CIImage *watermarkImage = self.watermarkCIImage;
                
                CGAffineTransform transform = CGAffineTransformMakeTranslation(self.watermarkPosition.x, backgroundImage.extent.size.height - watermarkImage.extent.size.height - self.watermarkPosition.y);
                CIImage *transformedWatermarkImage = [watermarkImage imageByApplyingTransform:transform];
                
                [watermarkFilter setValue:backgroundImage forKey:kCIInputBackgroundImageKey];
                [watermarkFilter setValue:transformedWatermarkImage forKey:kCIInputImageKey];
                
                image = watermarkFilter.outputImage;
            }
            
            [request finishWithImage:image context:renderingContext];
        }];
    } else {
        AVMutableVideoCompositionLayerInstruction *videoCompositionLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoCompositionTrack];
        
        QGChangeFrameVideoCompositionInstruction *videoCompositionInstruction = [QGChangeFrameVideoCompositionInstruction new];
        videoCompositionInstruction.frameTime = kCMTimeZero;
        videoCompositionInstruction.frameImage = _coverCIImage;
        videoCompositionInstruction.watermarkImage = _watermarkCIImage;
        videoCompositionInstruction.watermarkPosition = _watermarkPosition;
        
        videoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration);
        videoCompositionInstruction.layerInstructions = @[videoCompositionLayerInstruction];
        
        videoComposition = [AVMutableVideoComposition videoComposition];
        videoComposition.customVideoCompositorClass = QGChangeFrameCompositer.class;
        videoComposition.instructions = @[videoCompositionInstruction];
    }

    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.renderSize = naturalSize;
    
    // AVMutableAudioMix
    AVMutableAudioMix *audioMix = [self audioMixForAudioTracks];
    
    // 保存
    self.composition = composition.copy;
    self.videoComposition = videoComposition.copy;
    self.audioMix = audioMix.copy;
}

/**
 创建当前各个音频轨道的音频混合参数
 注意: self.audioAssets.eachOne.qg_compositionTracks需要已经被设置
 @return 音频混合参数
 */
- (AVMutableAudioMix *)audioMixForAudioTracks {
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    
    NSMutableArray<AVMutableAudioMixInputParameters *> *audioMixInputParametersArray = [NSMutableArray array];
    for (AVAsset *audioAsset in _audioAssets) {
        CGFloat volume = audioAsset.qg_volume;
        for (AVCompositionTrack *audioCompositionTrack in audioAsset.qg_compositionTracks) {
            AVMutableAudioMixInputParameters *audioMixInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioCompositionTrack];
            audioMixInputParameters.trackID = audioCompositionTrack.trackID;
            [audioMixInputParameters setVolume:volume atTime:kCMTimeZero];
            
            [audioMixInputParametersArray addObject:audioMixInputParameters];
        }
    }
    
    audioMix.inputParameters = audioMixInputParametersArray;
    
    return audioMix;
}

- (void)testAsset:(AVAsset *)asset videoDuration:(CMTime)duration type:(AVMediaType)type {
    // type只可能是视频或音频
    NSString *mediaType = (type == AVMediaTypeVideo ? @"视频" : @"音频");
    
    NSString *alertMessage = [NSString stringWithFormat:@"%@在合成后的视频中的开始时间必须合法!", mediaType];
    NSAssert(CMTimeRangeContainsTime(CMTimeRangeMake(kCMTimeZero, duration), asset.qg_startTimeInCompositedVideo), alertMessage);
    
    alertMessage = [NSString stringWithFormat:@"%@时长必须非0!", mediaType];
    NSAssert(CMTIME_COMPARE_INLINE(asset.qg_timeRangeUsedToComposite.duration, >, kCMTimeZero), alertMessage);
    
    alertMessage = [NSString stringWithFormat:@"用于播放的%@时间范围必须合法!", mediaType];
    NSAssert(CMTimeRangeContainsTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), asset.qg_timeRangeUsedToComposite), alertMessage);
}

#pragma mark - Setters

- (void)setCoverImage:(UIImage *)coverImage {
    _coverImage = coverImage;
    _coverCIImage = (_coverImage ? [CIImage imageWithCGImage:_coverImage.CGImage] : nil);
    
    QGChangeFrameVideoCompositionInstruction *instruction = (QGChangeFrameVideoCompositionInstruction *)_videoComposition.instructions.firstObject;
    if ([instruction isKindOfClass:QGChangeFrameVideoCompositionInstruction.class]) {
        instruction.frameImage = _coverCIImage;
    }
}

- (void)setWatermarkImage:(UIImage *)watermarkImage {
    _watermarkImage = watermarkImage;
    _watermarkCIImage = (_watermarkImage ? [CIImage imageWithCGImage:_watermarkImage.CGImage] : nil);
    
    QGChangeFrameVideoCompositionInstruction *instruction = (QGChangeFrameVideoCompositionInstruction *)_videoComposition.instructions.firstObject;
    if ([instruction isKindOfClass:QGChangeFrameVideoCompositionInstruction.class]) {
        instruction.watermarkImage = _watermarkCIImage;
    }
}

- (void)setWatermarkPosition:(CGPoint)watermarkPosition {
    _watermarkPosition = watermarkPosition;
    
    QGChangeFrameVideoCompositionInstruction *instruction = (QGChangeFrameVideoCompositionInstruction *)_videoComposition.instructions.firstObject;
    if ([instruction isKindOfClass:QGChangeFrameVideoCompositionInstruction.class]) {
        instruction.watermarkPosition = _watermarkPosition;
    }
}

#pragma mark - 音量

- (void)setVolume:(CGFloat)volume forAsset:(AVAsset *)audioAsset {
    [self setVolume:volume forAssets:@[audioAsset]];
}

- (void)setVolume:(CGFloat)volume forAssets:(NSArray<AVAsset *> *)audioAssets {
    for (AVAsset *audioAsset in audioAssets) {
        audioAsset.qg_volume = volume;
    }
    
    self.audioMix = [self audioMixForAudioTracks].copy;
}

#pragma mark - 音频轨道操作

- (void)resetAudioAssets:(NSArray<AVAsset *> *)audioAssets {
    [self resetVideoAsset:_videoAsset audioAssets:audioAssets];
}

- (void)resetVideoAsset:(AVAsset *)videoAsset audioAssets:(NSArray<AVAsset *> *)audioAssets {
    /* 更新视频轨道和音频轨道 */
    _videoAsset = videoAsset;
    _audioAssets = audioAssets;
    
    /* 重置视频轨道和音频轨道 */
    [self setup];
}

#pragma mark - AVPlayerItem

- (AVPlayerItem *)playerItem {
    NSParameterAssert(_composition);
    NSParameterAssert(_videoComposition);
    NSParameterAssert(_audioMix);
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:_composition];
    playerItem.videoComposition = _videoComposition;
    playerItem.audioMix = _audioMix;
    
    return playerItem;
}

#pragma mark - 导出

- (void)cancelExport {
    [_videoExporter cancelExport];
}

- (void)exportVideoToPath:(NSString *)videoOutputPath
                 progress:(void(^_Nullable)(CGFloat progress))progress
                 canceled:(void (^_Nullable)(void))canceled
                 finished:(void(^_Nullable)(NSError *error))finished {
    NSParameterAssert(_composition);
    NSParameterAssert(_videoComposition);
    NSParameterAssert(_audioMix);
    
    _videoExporter = [[QGVideoExporter alloc] initWithAsset:_composition audioMix:_audioMix videoComposition:_videoComposition];
    [_videoExporter exportVideoToPath:videoOutputPath progress:progress canceled:canceled finished:finished];
}

#pragma mark - Dealloc

- (void)dealloc {
    
}

@end
