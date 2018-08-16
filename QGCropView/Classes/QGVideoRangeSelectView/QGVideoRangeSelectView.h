//
//  QGVideoRangeSelectView.h
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/4/2.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface QGVideoRangeSelectView : UIView

@property (nonatomic, strong) AVAsset *videoAsset;///< 原视频
@property (nonatomic, assign) CMTimeRange selectedTimeRange;///< 选择的时间范围

@property (nonatomic, copy) void (^willBeginSelectingTimeRange)(void);
@property (nonatomic, copy) void (^selectedTimeRangeChanged)(CMTimeRange selectedTimeRange);

@end
