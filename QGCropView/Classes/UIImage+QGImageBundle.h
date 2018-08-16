//
//  UIImage+QGImageBundle.h
//  QGImagePicker
//
//  Created by 宇园 on 2018/2/26.
//

#import <UIKit/UIKit.h>

@interface UIImage (QGImageBundle)

+ (UIImage *)qg_imageNamed:(NSString *)imageName
        bundleResourceName:(NSString *)resourceName
            aClassInBundle:(Class)aClass;

@end
