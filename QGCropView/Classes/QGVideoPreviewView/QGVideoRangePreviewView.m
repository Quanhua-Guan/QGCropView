//
//  QGRangeVideoPreviewView.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/30.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGVideoRangePreviewView.h"
#import "QGMacro.h"

@implementation QGVideoRangePreviewView

#pragma mark - 控制

- (void)play {
    if (self.isPlaying) {
        return;
    }
    
    if (!CMTimeRangeContainsTime(_playTimeRange, self.currentTime)) {
        [self seekToTime:self.playTimeRange.start];
    }
    
    [super play];
    [self setupPeriodicTimer];
}

- (void)pause {
    if (!self.isPlaying) {
        return;
    }
    
    [super pause];
    [self removePeriodicTimerIfHasOne];
}

#pragma mark - 计时器

- (void)setupDidPlayToVideoEndTimeHandler {
    @weakify(self);
    self.videoDidPlayToEndTimeActionBlock = ^{
        @strongify(self);
        [self handleDidPlayToEnd];
    };
}

- (void)setupPeriodicTimer {
    @weakify(self);
    [self resetPeriodicTimerInterval:CMTimeMake(1, 20) usingBlock:^(CMTime time) {
        @strongify(self);
        if (self.didPlayToTime) {
            self.didPlayToTime(time, [self duration]);
        }
        CMTime endTime = CMTimeAdd(self.playTimeRange.start, self.playTimeRange.duration);
        if (CMTIME_COMPARE_INLINE(time, >=, endTime)) {
            [self handleDidPlayToEnd];
        }
    }];
}

/**
 处理播放到达视频总时长结尾, 或则设置的播放时间区间的终点时的处理
 */
- (void)handleDidPlayToEnd {
    [self seekToTime:self.playTimeRange.start];
    if (self.loop) {
        [self play];
    } else {
        [self pause];
    }
}

#pragma mark - Setters

- (void)setPlayTimeRange:(CMTimeRange)playTimeRange {
    CMTime duration = [self duration];
    NSAssert(CMTIME_COMPARE_INLINE(duration, !=, kCMTimeZero), @"视频时长不可以为0!");
    
    _playTimeRange = CMTimeRangeGetIntersection(playTimeRange, CMTimeRangeMake(kCMTimeZero, duration));
    if (!CMTimeRangeContainsTime(_playTimeRange, self.currentTime)) {
        [self seekToTime:_playTimeRange.start];
    }
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    super.playerItem = playerItem;
    
    _playTimeRange = CMTimeRangeMake(kCMTimeZero, self.duration);    
    [self setupDidPlayToVideoEndTimeHandler];
}

@end
