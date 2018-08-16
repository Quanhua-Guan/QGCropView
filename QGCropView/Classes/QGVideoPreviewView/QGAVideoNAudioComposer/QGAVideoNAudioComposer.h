//
//  QGAVideoNAudioCompositer.h
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/21.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 1个视频轨道(只使用视频轨道) + N段音频轨道(覆盖部分视频时长的短音频, 或覆盖整个视频时长背景音频) 的视频合成器
 支持实时调整每个音频轨道的音量
 最终会生成对应的AVComposition, AVAudioMix, AVVdieoComposition, 可用于生成AVPlayerItem或AVAssetExportSession.
 */
@interface QGAVideoNAudioComposer : NSObject

@property (nonatomic, strong, readonly) AVAsset *videoAsset;///< 1个视频轨道(整个视频以视频轨道时间线为准)
@property (nonatomic, strong, readonly) NSArray<AVAsset *> *audioAssets;///< 多个音频轨道

@property (nonatomic, strong, readonly) AVComposition *composition;///< 合成视频资源, 可用于创建AVPlayerItem
@property (nonatomic, strong, readonly) AVAudioMix *audioMix;///< 合成视频的音频混合配置
@property (nonatomic, strong, readonly) AVVideoComposition *videoComposition;///< 合成视频的视频渲染配置

@property (nonatomic, strong) UIImage *coverImage;///< 封面图片
@property (nonatomic, strong) UIImage *watermarkImage;///< 水印图片
@property (nonatomic, assign) CGPoint watermarkPosition;///< 水印图片位置(单位:像素)

/**
 初始化合成器
 注意:
 1. 以videoAsset.qg_timeRange为视频时长范围, (audioAssets).qg_timeRange中包含了轨道的播放时间范围(以视频轨道的时间范围为参考);
 2. videoAsset.qg_timeRange.start一定为kCMTimeZero, videoAsset.qg_timeRange.duration为视频总时长.
 
 @param videoAsset 视频轨道
 @param audioAssets 音频轨道数组
 @return 视频合成器
 */
- (instancetype)initWithVideoAsset:(AVAsset *)videoAsset audioAssets:(NSArray<AVAsset *> *)audioAssets;

/**
 实时设置一段音轨的音量
 音量设置后只生成新的audioMix, 不影响composition和videoComposition.
 
 @param volume 音量, 范围[0, 1]
 @param audioAsset 音频轨道, 需要属于audioAssets, 否则无法成功修改音量.
 */
- (void)setVolume:(CGFloat)volume forAsset:(AVAsset *)audioAsset;

/**
 实时设置多段音轨音量
 音量设置后只生成新的audioMix, 不影响composition和videoComposition.
 
 @param volume 音量, 范围[0, 1]
 @param audioAssets 多段音频轨道, 每段都需要属于audioAssets.
 */
- (void)setVolume:(CGFloat)volume forAssets:(NSArray<AVAsset *> *)audioAssets;

/**
 重置音频轨道
 将会重置视频合成器, 重新生成新的audioMix, composition和videoComposition.
 
 @param audioAssets 新的音频轨道数组
 */
- (void)resetAudioAssets:(NSArray<AVAsset *> *)audioAssets;

/**
 重置视频轨道和音频轨道
 将会重置视频合成器, 重新生成新的audioMix, composition和videoComposition.
 
 @param videoAsset 视频轨道
 @param audioAssets 音频轨道数组
 */
- (void)resetVideoAsset:(AVAsset *)videoAsset audioAssets:(NSArray<AVAsset *> *)audioAssets;

/**
 生成新的视频播放项

 @return 新的播放项
 */
- (AVPlayerItem *)playerItem;

/**
 取消视频导出操作
 */
- (void)cancelExport;

/**
 导出视频

 @param videoOutputPath 视频导出后写入的路径
 @param progress 导出进度回调, 返回进度[0, 1.0]
 @param canceled 取消导出操作的回调
 @param finished 导出操作完成, error为nil, 则导出成功, 否则导出失败.
 */
- (void)exportVideoToPath:(NSString *)videoOutputPath
                 progress:(void(^_Nullable)(CGFloat progress))progress
                 canceled:(void (^_Nullable)(void))canceled
                 finished:(void(^_Nullable)(NSError *error))finished;

@end

NS_ASSUME_NONNULL_END
