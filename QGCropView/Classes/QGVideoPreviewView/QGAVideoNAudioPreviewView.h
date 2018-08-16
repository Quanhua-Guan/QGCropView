//
//  QGAVideoNAudioPreviewView.h
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/14.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGVideoRangePreviewView.h"
#import "AVAsset+QGAVideoNAudioPreviewView.h"

/**
 1个视频轨道(只使用视频轨道) + N段音频轨道(覆盖部分视频时长的短音频, 或覆盖整个视频时长背景音频) 的播放器
 支持实时调整每个音频轨道的音量
 */
@interface QGAVideoNAudioPreviewView : QGVideoRangePreviewView

@property (nonatomic, strong, readonly) AVAsset *videoAsset;///< 1个视频轨道(整个视频以视频轨道时间线为准)
@property (nonatomic, strong, readonly) NSArray<AVAsset *> *audioAssets;///< 多个音频轨道

@property (nonatomic, strong) UIImage *watermarkImage;///< 水印图片
@property (nonatomic, assign) CGPoint watermarkPosition;///< 水印距离视频帧左上角距离(单位:像素)

/**
 初始化播放器
 注意:
 1. 以videoAsset.qg_timeRange为视频时长范围, (audioAssets).qg_timeRange中包含了轨道的播放时间范围(以视频轨道的时间范围为参考);
 2. videoAsset.qg_timeRange.start一定为kCMTimeZero, videoAsset.qg_timeRange.duration为视频总时长.

 @param videoAsset 视频轨道
 @param audioAssets 音频轨道数组
 @return 播放器
 */
- (instancetype)initWithVideoAsset:(AVAsset *)videoAsset audioAssets:(NSArray<AVAsset *> *)audioAssets;

/**
 实时设置一段音轨音量

 @param volume 音量, 范围[0, 1]
 @param audioAsset 音频轨道, 需要属于audioAssets.
 */
- (void)setVolume:(CGFloat)volume forAsset:(AVAsset *)audioAsset;

/**
 实时设置多段音轨音量
 
 @param volume 音量, 范围[0, 1]
 @param audioAssets 多段音频轨道, 每段都需要属于audioAssets.
 */
- (void)setVolume:(CGFloat)volume forAssets:(NSArray<AVAsset *> *)audioAssets;

/**
 重置音频轨道
 将会重置播放器

 @param audioAssets 新的音频轨道数组
 */
- (void)resetAudioAssets:(NSArray<AVAsset *> *)audioAssets;

/**
 重置视频轨道和音频轨道
 将会重置播放器

 @param videoAsset 视频轨道
 @param audioAssets 音频轨道数组
 */
- (void)resetVideoAsset:(AVAsset *)videoAsset audioAssets:(NSArray<AVAsset *> *)audioAssets;

@end
