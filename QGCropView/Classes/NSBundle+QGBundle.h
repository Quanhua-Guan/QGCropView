//
//  NSBundle+QGBundle.h
//  AFNetworking
//
//  Created by 宇园 on 2018/2/26.
//

#import <Foundation/Foundation.h>

@interface NSBundle (QGBundle)

+ (NSBundle *)qg_bundleWithClass:(Class)aClass resourceName:(NSString *)resourceName;

@end
