//
//  QGVideoCropViewController.h
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/4/2.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "QGBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class QGCropSetting;

/**
 视频裁剪页面
 */
@interface QGVideoCropViewController : QGBaseViewController

@property (nonatomic, assign) CGSize cropPixelSize;///< 目标裁剪大小, 单位:像素
@property (nonatomic, strong) AVAsset *originVideoAsset;///< 原视频
@property (nonatomic, strong) UIImage *maskImage;///< 遮罩图, 仅用于遮罩, 不会在裁剪操作中使用到
@property (nonatomic, strong) QGCropSetting *cropSetting;///< 当前的裁剪设置, 包括旋转+缩放+平移参数
@property (nonatomic, assign) CMTimeRange selectedTimeRange;///< 选择的时间范围
@property (nonatomic, assign) CGFloat preferredFPS;///< 导出视频的帧率

@property (nonatomic, strong) UIImage *cancelButtonImage;///< 取消按钮图标
@property (nonatomic, strong) UIImage *doneButtonImage;///< 确定按钮图标

@property (nonatomic, assign) BOOL dontCloseWhenDone;///< 完成时不自动关闭页面, 默认NO, 即默认会自动关闭

@property (nonatomic, copy) void (^cancelBlock)(void);///< 取消回调, 即关闭裁剪页面时的回调
@property (nonatomic, copy) void (^doneWithCropSettingBlock)(QGCropSetting *cropSetting, CGSize cropPixelSize, CMTimeRange selectedTimeRange);///< 完成裁剪的回调, 返回当前的裁剪设置+目标裁剪大小(单位:像素)+选定时间范围

/**
 执行裁剪&导出操作前的回调, 注意: 如果willCropVideoBlock为空, 则使用默认的SVProgressHUD显示进度; 否则,如果该值为非空, 则进度显示应该由调用方处理; 参考cropVideoProgressBlock, cropVideoCancelBlock, cropVideoFinishedBlock;
 */
@property (nonatomic, copy) void (^willCropVideoBlock)(void);
@property (nonatomic, copy) void (^cropVideoProgressBlock)(CGFloat progress);///< 视频导出进度回调
@property (nonatomic, copy) void (^cropVideoCancelBlock)(void);///< 导出过程被用户取消的回调
@property (nonatomic, copy) void (^cropVideoFinishedBlock)(NSError *_Nullable error, NSString *croppedVideoPath);///< 完成裁剪&导出的回调; 如果error为非nil, 则失败; 成功时, error为nil, 返回裁剪后的视频路径(导出视频过程是异步的).

@end

NS_ASSUME_NONNULL_END
