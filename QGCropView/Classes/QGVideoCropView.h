//
//  QGVideoCropView.h
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/30.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGCropView.h"
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QGVideoCropView : QGCropView

@property (nonatomic, strong) AVAsset *originVideoAsset;///< 原视频资源
@property (nonatomic, assign) CMTimeRange cropTimeRange;///< 被裁剪的时间范围

/**
 播放视频
 */
- (void)play;

/**
 暂停视频
 */
- (void)pause;

/**
 取消导出视频
 */
- (void)cancelExport;

/**
 导出裁剪后的视频

 @param videoOutputPath 视频导出后写入的路径
 @param preferredFPS 导出视频帧率
 @param progress 导出进度回调, 返回进度[0, 1.0]
 @param canceled 取消导出操作的回调
 @param finished 导出操作完成, error为nil, 则导出成功, 否则导出失败.
 */
- (void)exportVideoToPath:(NSString *)videoOutputPath
             preferredFPS:(CGFloat)preferredFPS
                 progress:(void(^_Nullable)(CGFloat progress))progress
                 canceled:(void (^_Nullable)(void))canceled
                 finished:(void(^_Nullable)(NSError *_Nullable error))finished;

@end

NS_ASSUME_NONNULL_END
