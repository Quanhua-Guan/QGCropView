//
//  AVURLAsset+Size.m
//  QGCropView
//
//  Created by 宇园 on 2017/7/24.
//  Copyright © 2017年 CQMH. All rights reserved.
//

#import "AVAsset+QGCommon.h"

@implementation AVAsset (QGSize)

- (CGSize)qg_videoSize {
    NSArray<AVAssetTrack *> *videoTracks = [self tracksWithMediaType:AVMediaTypeVideo];
    CGSize size = CGSizeZero;
    AVAssetTrack *track = videoTracks.firstObject;
    size = [track naturalSize];
    size = CGSizeApplyAffineTransform(size, track.preferredTransform);
    size = CGSizeMake(fabs(size.width), fabs(size.height));
    
    BOOL isSizeOK = isfinite(size.width) && isfinite(size.height) && size.width > 0 && size.height > 0;
    if (!isSizeOK) {
        size = CGSizeMake(UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.width);// 默认值
    }
    
    return size;
}

- (nullable UIImage *)qg_lastFrameImage {
    return [self qg_imageAtCMTime:self.duration];
}

- (nullable UIImage *)qg_imageAtCMTime:(CMTime)time {
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:self];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef imageRef = NULL;
    __autoreleasing NSError * error = nil;
    imageRef = [assetImageGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    
    if (imageRef == nil || error != nil) {
        return nil;
    } else {
        UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
        CGImageRelease(imageRef);
        return image;
    }
}

- (nullable UIImage *)qg_imageAtTime:(NSTimeInterval)time {
    return [self qg_imageAtCMTime:CMTimeMake(time * 30, 30)] ?: nil;
}

@end
