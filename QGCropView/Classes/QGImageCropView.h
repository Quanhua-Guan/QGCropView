//
//  QGImageCropView.h
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/27.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGCropView.h"

/**
 图片裁剪视图
 */
@interface QGImageCropView : QGCropView

@property (nonatomic, strong) UIImage *originImage;///< 原图, 设置该值将更新contentPixelSize
@property (nonatomic, strong, readonly) UIImage *croppedImage;///< 裁剪得到的结果图

@end
