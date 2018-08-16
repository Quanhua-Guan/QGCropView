//
//  QGCropView.h
//  QGCropView
//
//  Created by 宇园 on 2018/3/26.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QGCropViewGestureProtocol <NSObject>

- (void)rotateGestureHandler:(UIRotationGestureRecognizer *)gesture;
- (void)pinchGestureHandler:(UIPinchGestureRecognizer *)gesture;
- (void)panGestureHandler:(UIPanGestureRecognizer *)gesture;

@end

/**
 裁剪操作参数, 操作分三步, 按顺序如下:
 1. 围绕被裁剪区域中心点, 旋转rotation弧度,
 2. 然后, 围绕被裁剪区域中心点, 缩放scale倍,
 3. 最后, 平移 (translation.x, translation.y).
 */
@interface QGCropSetting : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, assign) CGFloat rotation;///< 旋转角度, 单位:弧度, 默认值0
@property (nonatomic, assign) CGFloat scale;///< 缩放倍数, 默认值1
@property (nonatomic, assign) CGPoint translation;///< 平移距离, 该值为绝对值, 单位:点或像素(与cropSize单位一致), 默认值(0, 0)
@property (nonatomic, assign) CGSize cropSize;///< 裁剪区域, 该值为绝对值, 单位:点或像素(与translation单位一致), 默认值(1, 1)

/**
 相对移动距离, 即 (translation.x / cropSize.width, translation.y / cropSize.height)
 @return 相对移动距离
 */
- (CGPoint)relativeTranslation;

@end

/**
 图片/视频裁剪视图
 被裁剪的视频/图片必须为一个正矩形(即未被缩放/旋转)
 */
@interface QGCropView : UIView <QGCropViewGestureProtocol>

/**
 目标裁剪大小(单位:像素), 不设置时, 默认为被裁剪内容的大小
 注意: 如果要做两个裁剪视图的操作同步, 则cropPixelSize和contentPixelSize必须一致.
 */
@property (nonatomic, assign) CGSize cropPixelSize;
/**
 被裁剪内容的实际像素大小(单位:像素)
 注意: 如果要做两个裁剪视图的操作同步, 则cropPixelSize和contentPixelSize必须一致.
 */
@property (nonatomic, assign) CGSize contentPixelSize;

@property (nonatomic, copy, readonly) QGCropSetting *cropSetting;///< 当前的旋转/缩放/平移操作参数
@property (nonatomic, assign, readonly) CGFloat rotation;///< 旋转角度, 单位:弧度
@property (nonatomic, assign, readonly) CGFloat scale;///< 缩放倍数
@property (nonatomic, assign, readonly) CGPoint relativeTranslation;///< 平移了相对视窗

/**
 当前的旋转/缩放/平移的数据(注意:这三个操作互不影响, 且都是相对值) + 当前操作是否进行了动画
 比如对一张图片进行裁剪, 这三个值对应的操作为:
 0. 目标裁剪区域与图片居中对齐, 且图片以AspectFill的方式填满目标裁剪区域,
 1. 图片绕其中心点旋转cropSetting.rotation弧度,
 2. 然后, 图片缩放cropSetting.scale倍, (执行完此步操作后, 图片的中心点和目标裁剪区域的中心点依然是重合的)
 3. 最后, 在1步和第2步的基础上, 图片平移tran=(cropSetting.relativeTranslation.x * 目标裁剪区域宽度, cropSetting.relativeTranslation.y * 目标裁剪区域高度), 即距离目标裁剪区域中心距离tran. (这里强调'在1步和第2步的基础上', 目的是想说明x,y轴方向已经受到旋转+缩放的影响, 也就是说tran是在之前旋转+缩放基础上的平移值)
 根据以上三个值, 以及cropPixelSize和contentPixelSize, 就可以推算出图片中被裁剪的区域.
 */
@property (nonatomic, copy) void(^settingsChanged)(QGCropSetting *cropSetting, BOOL animate);

@property (nonatomic, copy) void(^willStartCropping)(void);///< 将要开始操作(旋转/缩放/平移)
@property (nonatomic, copy) void(^didEndCropping)(void);///< 已经完成操作(旋转/缩放/平移)

@property (nonatomic, assign) UIEdgeInsets minimalInset;///< 裁剪视图最小的内边距, 单位:点, 即视窗视图四个边距离裁剪视图四个边的最小距离, 默认UIEdgeInsetsZero
@property (nonatomic, strong) UIColor *maskColor;///< 视窗周围遮罩的颜色
@property (nonatomic, assign) BOOL hideMask;///< 隐藏遮罩
@property (nonatomic, assign) BOOL disableRotation;///< 关闭旋转功能, 默认开启
@property (nonatomic, assign) BOOL disablePinch;///< 关闭缩放功能, 默认开启
@property (nonatomic, assign) BOOL disablePan;///< 关闭平移功能, 默认开启

/**
 设置要裁剪的的内容视图
 @param content 包含被裁剪内容的视图, 该视图将会被重新设置大小和布局
 */
- (void)resetContent:(UIView *)content;

/**
 更新旋转/缩放/平移参数

 @param cropSetting 旋转/缩放/平移参数
 @param animate 是否动画
 @param adjust 操作后是否调整缩放+平移参数,以保证视窗区域被被裁剪内容填满
 */
- (void)updateCropSetting:(QGCropSetting *)cropSetting animate:(BOOL)animate adjust:(BOOL)adjust;

/**
 更新旋转/缩放/平移参数

 @param rotation 旋转角度
 @param scale 缩放倍数
 @param translation 相对移动距离(注意该值为相对值)
 @param animate 是否动画
 @param adjust 操作后是否调整缩放+平移参数,以保证视窗区域被被裁剪内容填满
 */
- (void)updateRotation:(CGFloat)rotation scale:(CGFloat)scale translation:(CGPoint)translation animate:(BOOL)animate adjust:(BOOL)adjust;

/**
 更新旋转/缩放/平移参数
 
 @param rotation 旋转角度
 @param animate 是否动画
 @param adjust 操作后是否调整缩放+平移参数,以保证视窗区域被被裁剪内容填满
 */
- (void)updateRotation:(CGFloat)rotation animate:(BOOL)animate adjust:(BOOL)adjust;

/**
 更新缩放参数
 @param scale 缩放倍数
 @param animate 是否动画
 @param adjust 操作后是否调整缩放+平移参数,以保证视窗区域被被裁剪内容填满
 */
- (void)updateScale:(CGFloat)scale animate:(BOOL)animate adjust:(BOOL)adjust;

/**
 更新平移参数
 @param translation 相对移动距离(注意该值为相对值)
 @param animate 是否动画
 @param adjust 操作后是否调整缩放+平移参数,以保证视窗区域被被裁剪内容填满
 */
- (void)updateTranslation:(CGPoint)translation animate:(BOOL)animate adjust:(BOOL)adjust;

@end
