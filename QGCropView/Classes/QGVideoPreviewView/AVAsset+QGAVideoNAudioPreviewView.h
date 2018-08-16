//
//  QGAsset+QGAVideoNAudioPreviewView.h
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/15.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAsset (QGAVideoNAudioPreviewView)

@property (nonatomic, assign) CMTime qg_startTimeInCompositedVideo;///< 在目标完整视频时长范围内的开始时间
@property (nonatomic, assign) CMTimeRange qg_timeRangeUsedToComposite;///< 当前资源用于合成的时间区间
@property (nonatomic, strong) NSArray<AVCompositionTrack *> *qg_compositionTracks;///< 对应的AVComposition中tracks的(视频或音频)资源轨道
@property (nonatomic, assign) CGFloat qg_volume;///< 音量, 范围[0, 1.0], 默认0

@end
