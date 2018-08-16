//
//  QGTool.m
//  QGCropView
//
//  Created by 宇园 on 2018/8/16.
//

#import "QGTool.h"
#import "SDVersion.h"

@implementation QGTool

+ (BOOL)iPhoneX {
    return [SDVersion deviceVersion] == iPhoneX;
}

@end
