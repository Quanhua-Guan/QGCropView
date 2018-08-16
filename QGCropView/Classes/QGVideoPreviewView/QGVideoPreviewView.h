//
//  QGVideoPreviewView.h
//  QGCropView
//
//  Created by 宇园 on 2017/12/19.
//  Copyright © 2017年 CQMH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

/**
 基础视频播放器
 */
@interface QGVideoPreviewView : UIView

@property (nonatomic, strong) NSURL *videoURL; ///< 视频路径 支持本地和网络2种
@property (nonatomic, strong) AVPlayerItem *playerItem;///< 视频
@property (nonatomic, assign) BOOL loop;///< 是否循环播放, 默认YES
@property (nonatomic, assign) CGFloat volume;///< 整个视频的音量
@property (nonatomic, assign, readonly) CMTime currentTime;///< 当前播放时间
@property (nonatomic, assign, readonly) CMTime duration;///< 视频时长

/**
 视频播放结束(播放完最后一秒)时的回调
 注意:
 1. 如果本回调为空, 则调用默认操作(循环时,重头开始播放; 不循环时跳转到开头, 暂停播放);
 2. 如果本回调不为空, 则调用本回调的处理, 不调用默认操作;
 */
@property (nonatomic, copy) void(^videoDidPlayToEndTimeActionBlock)(void);

/**
 基础配置
 */
- (void)setup;

/**
 设置周期计时器, 获取视频的当前播放时间
 @param interval 计时器回调间隔
 @param block 计时器回调Block
 */
- (void)resetPeriodicTimerInterval:(CMTime)interval usingBlock:(void (^)(CMTime time))block;

/**
 如果存在的话, 移除周期计时器
 */
- (void)removePeriodicTimerIfHasOne;

- (void)seekToTime:(CMTime)time;
- (void)play;
- (void)pause;
- (BOOL)isPlaying;

/**
 创建一个新的播放器图层, 播放的视频和播放器视图一致. 用于支持多个窗口同时播放一个视频.
 
 @return 一个新的播放器图层
 */
- (AVPlayerLayer *)createAnotherPlayerLayer;

@end
