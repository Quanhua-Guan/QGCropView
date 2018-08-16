//
//  QGVideoRangePreviewView.h
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/30.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGVideoPreviewView.h"

@interface QGVideoRangePreviewView : QGVideoPreviewView

/**
 播放时间区间, 默认为视频时长范围.
 播放时间区间需要在视频时长范围内, 内部会进行范围限制, 如果设置的值与视频时长范围无交集, 则设置为视频时长范围.
 注意: 如果设置该值时播放时间不属于新的时间区间, 则会将播放时间SEEK到playerTimeRange.start位置. 
 */
@property (nonatomic, assign) CMTimeRange playTimeRange;

/**
 当前播放时间更新回调
 */
@property (nonatomic, copy) void(^didPlayToTime)(CMTime currentTime, CMTime totalTime);

@end
