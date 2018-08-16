//
//  QGChangeFrameVideoCompositionInstruction.h
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/28.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface QGChangeFrameVideoCompositionInstruction : AVMutableVideoCompositionInstruction

@property (nonatomic, assign) CMTime frameTime;///< 被替换帧的时间
@property (nonatomic, strong) CIImage *frameImage;///< 目标帧图片, 即替换后的帧图片

@property (nonatomic, strong) CIImage *watermarkImage;///< 水印图片
@property (nonatomic, assign) CGPoint watermarkPosition;///< 水印图片左上角原点在整个视频帧中的位置(单位: 像素)

@end
