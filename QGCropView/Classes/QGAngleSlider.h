//
//  AngleSlider.h
//  QGCropView
//
//  Created by 宇园 on 2018/4/1.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 角度变化Slider视图
 */
@interface QGAngleSlider : UIView

/**
 滑块图片, 大小25x25(单位:点)
 */
@property (nonatomic, strong) UIImage *thumbImage;
/**
 角度, 所有角度将会被转换成 -180°~+180°, 即 -180°-1° => 179°, 180°+1° => -179°. 单位: 度(°)
 */
@property (nonatomic, assign) CGFloat angle;
/**
 角度值变化的回调
 newAngle 当前角度, 单位为角度(°)
 shouldAnimate 是否需要动画
 */
@property (nonatomic, copy) void (^angleChanged)(CGFloat newAngle, BOOL shouldAnimate);
/**
 将要开始变化角度的回调
 */
@property (nonatomic, copy) void (^willStartChangingAngle)(void);
/**
 已经结束角度变化的回调
 */
@property (nonatomic, copy) void (^didEndChangingAngle)(void);

@end
