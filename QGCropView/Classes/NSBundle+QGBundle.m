//
//  NSBundle+QGBundle.m
//  AFNetworking
//
//  Created by 宇园 on 2018/2/26.
//

#import "NSBundle+QGBundle.h"
#include <objc/objc.h>

@implementation NSBundle (QGBundle)

+ (NSBundle *)qg_bundleWithClass:(Class)aClass resourceName:(NSString *)resourceName
{
    NSString *bundlePath = [[NSBundle bundleForClass:aClass] pathForResource:resourceName ofType:@"bundle"];
    return [NSBundle bundleWithPath:bundlePath];
}

@end
