//
//  UIImage+QGImageBundle.m
//  QGImagePicker
//
//  Created by 宇园 on 2018/2/26.
//

#import "UIImage+QGImageBundle.h"
#import "NSBundle+QGBundle.h"

@implementation UIImage (QGImageBundle)

+ (UIImage *)qg_imageNamed:(NSString *)imageName
        bundleResourceName:(NSString *)resourceName
            aClassInBundle:(Class)aClass
{
    return [UIImage imageNamed:imageName inBundle:[NSBundle qg_bundleWithClass:aClass resourceName:resourceName] compatibleWithTraitCollection:nil];
}

@end
