//
//  QGImageCropView.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/27.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGImageCropView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+QGExtra.h"

@interface QGImageCropView ()

@end

@implementation QGImageCropView

#pragma mark - Setters

- (void)setOriginImage:(UIImage *)originImage {
    _originImage = [originImage qg_fixOrientation];
    
    CGSize pixelSize = CGSizeMake(_originImage.size.width * _originImage.scale, _originImage.size.height * _originImage.scale);
    self.contentPixelSize = pixelSize;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_originImage];
    [self resetContent:imageView];
}

- (UIImage *)croppedImage {
    if (_originImage.size.width * _originImage.scale == self.cropPixelSize.width
        && _originImage.size.height * _originImage.scale == self.cropPixelSize.height
        && self.rotation == 0
        && self.scale == 1.0f
        && CGPointEqualToPoint(self.relativeTranslation, CGPointZero)) {
        return _originImage;
    }
    
    UIImage *croppedImage = nil;
    UIGraphicsBeginImageContextWithOptions(self.cropPixelSize, NO, 1);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
       
        /* 旋转+缩放 */
        CGContextTranslateCTM(context, self.cropPixelSize.width / 2, self.cropPixelSize.height / 2);
        CGContextRotateCTM(context, self.rotation);
        CGContextScaleCTM(context, self.scale, self.scale);
        CGContextTranslateCTM(context, -self.cropPixelSize.width / 2, -self.cropPixelSize.height / 2);

        /* 平移 */
        CGFloat translateX = self.relativeTranslation.x * self.cropPixelSize.width;
        CGFloat translateY = self.relativeTranslation.y * self.cropPixelSize.height;
        CGContextTranslateCTM(context, translateX, translateY);

        CGRect bounds = CGRectZero;
        bounds.size = self.contentPixelSize;
        CGSize size = AVMakeRectWithAspectRatioInsideRect(self.cropPixelSize, bounds).size;
        CGFloat scale = self.cropPixelSize.width / size.width;
        CGSize imageSize = CGSizeMake(self.contentPixelSize.width * scale, self.contentPixelSize.height * scale);

        CGRect imageFrame = CGRectMake((self.cropPixelSize.width - imageSize.width) / 2
                                       , (self.cropPixelSize.height - imageSize.height) / 2
                                       , imageSize.width
                                       , imageSize.height);

        CGContextTranslateCTM(context, 0, self.cropPixelSize.height);
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawImage(context, imageFrame, self.originImage.CGImage);
        
        croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return croppedImage;
}

@end
