//
//  UIImage+QGExtra.h
//  Tools
//
//  Created by apple on 15-1-19.
//  Copyright (c) 2015年 xmhouse. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (QGExtra)

- (UIImage *)qg_fixOrientation;

+ (UIImage *)qg_imageWithColor:(UIColor *)color andSize:(CGSize)size;

- (UIColor *)qg_opaqueColor;
- (UIColor *)qg_colorAtPixel:(CGPoint)point;
- (UIColor *)qg_colorAtPosition:(CGPoint)position;

@end

NS_ASSUME_NONNULL_END
