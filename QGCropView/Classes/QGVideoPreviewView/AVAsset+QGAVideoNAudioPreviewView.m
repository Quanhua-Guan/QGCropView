//
//  QGAsset+QGAVideoNAudioPreviewView.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/15.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "AVAsset+QGAVideoNAudioPreviewView.h"
#import "QGMacro.h"
#import <objc/runtime.h>

@implementation AVAsset (QGAVideoNAudioPreviewView)

QGSYNTH_DYNAMIC_PROPERTY_CTYPE(qg_startTimeInCompositedVideo, setQg_startTimeInCompositedVideo, CMTime)
QGSYNTH_DYNAMIC_PROPERTY_CTYPE(qg_timeRangeUsedToComposite, setQg_timeRangeUsedToComposite, CMTimeRange)
QGSYNTH_DYNAMIC_PROPERTY_OBJECT(qg_compositionTracks, setQg_compositionTracks, RETAIN_NONATOMIC, NSArray<AVCompositionTrack *> *)
QGSYNTH_DYNAMIC_PROPERTY_CTYPE(qg_volume, setQg_volume, CGFloat)

@end
