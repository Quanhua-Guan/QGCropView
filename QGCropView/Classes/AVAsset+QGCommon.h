//
//  AVURLAsset+QGSize.h
//  QGCropView
//
//  Created by 宇园 on 2017/7/24.
//  Copyright © 2017年 CQMH. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVAsset (QGSize)

/**
 获取视频的分辨率, 单位:像素
 如果获取的size无效或为CGSizeZero, 则返回默认Size{QG_SCREEN_WIDTH, QG_SCREEN_WIDTH}

 @return 视频的分辨率
 */
- (CGSize)qg_videoSize;

- (nullable UIImage *)qg_lastFrameImage;
- (nullable UIImage *)qg_imageAtCMTime:(CMTime)time;
- (nullable UIImage *)qg_imageAtTime:(NSTimeInterval)time;

@end
