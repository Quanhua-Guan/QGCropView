//
//  QGImageCropViewController.h
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/30.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGBaseViewController.h"
#import "QGImageCropView.h"

/**
 图片裁剪页面
 */
@interface QGImageCropViewController : QGBaseViewController

@property (nonatomic, assign) CGSize cropPixelSize;///< 目标裁剪大小, 单位:像素
@property (nonatomic, strong) UIImage *originImage;///< 原图
@property (nonatomic, strong) UIImage *maskImage;///< 遮罩图, 仅用于遮罩, 不会在裁剪操作中使用到
@property (nonatomic, strong) QGCropSetting *cropSetting;///< 当前的裁剪设置, 包括旋转+缩放+平移参数

@property (nonatomic, strong) UIImage *cancelButtonImage;///< 取消按钮图标
@property (nonatomic, strong) UIImage *doneButtonImage;///< 确定按钮图标

@property (nonatomic, assign) BOOL dontCloseWhenDone;///< 完成时不自动关闭页面, 默认NO, 即默认会自动关闭

@property (nonatomic, copy) void(^cancelBlock)(void);///< 取消回调, 即关闭裁剪页面时的回调
@property (nonatomic, copy) void(^doneWithCroppedImageBlock)(UIImage *cropedImage);///< 完成裁剪的回调, 若实现该回调, 则会进行图片裁剪并返回裁剪图片, 不实现时内部不会进行图片裁剪操作
@property (nonatomic, copy) void(^doneWithCropSettingBlock)(QGCropSetting *cropSetting, CGSize cropPixelSize);///< 完成裁剪的回调, 返回当前的裁剪设置+目标裁剪大小(单位:像素)

@end
