#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AVAsset+QGCommon.h"
#import "NSBundle+QGBundle.h"
#import "QGAngleSlider.h"
#import "QGBaseViewController.h"
#import "QGCropView.h"
#import "QGImageCropView.h"
#import "QGImageCropViewController.h"
#import "QGMacro.h"
#import "QGRotateView.h"
#import "QGTool.h"
#import "QGVideoCropView.h"
#import "QGVideoCropViewController.h"
#import "QGVideoExporter.h"
#import "UIImage+QGExtra.h"
#import "UIImage+QGImageBundle.h"

FOUNDATION_EXPORT double QGCropViewVersionNumber;
FOUNDATION_EXPORT const unsigned char QGCropViewVersionString[];

