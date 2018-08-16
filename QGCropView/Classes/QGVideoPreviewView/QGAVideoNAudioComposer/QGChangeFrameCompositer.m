//
//  QGChangeFrameCompositer.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/28.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGChangeFrameCompositer.h"
#import "QGChangeFrameVideoCompositionInstruction.h"

@interface QGChangeFrameCompositer ()

@property (nonatomic, assign) BOOL shouldCancelAllRequests;
@property (nonatomic, strong) dispatch_queue_t renderingQueue;
@property (nonatomic, strong) CIContext *renderingContext;

@end

@implementation QGChangeFrameCompositer

- (id)init {
    self = [super init];
    if (self) {
        _renderingQueue = dispatch_queue_create("com.hlg.QGChangeFrameCompositer.renderingQueue", DISPATCH_QUEUE_SERIAL);
        EAGLContext *eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        _renderingContext = [CIContext contextWithEAGLContext:eaglContext options:@{kCIContextWorkingColorSpace:[NSNull null]}];
    }
    return self;
}

- (NSDictionary<NSString *, id> *)sourcePixelBufferAttributes {
    return @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
             (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : @YES};
}

- (NSDictionary<NSString *, id> *)requiredPixelBufferAttributesForRenderContext {
    return @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
             (NSString*)kCVPixelBufferOpenGLESCompatibilityKey : @YES};
}

- (void)renderContextChanged:(AVVideoCompositionRenderContext *)newRenderContext {
    
}

- (void)startVideoCompositionRequest:(AVAsynchronousVideoCompositionRequest *)request
{
    @autoreleasepool {
        dispatch_async(_renderingQueue,^() {
            // Check if all pending requests have been cancelled
            if (self.shouldCancelAllRequests) {
                [request finishCancelledRequest];
            } else {
                NSError *error = nil;
                CVPixelBufferRef resultPixels = nil;
                BOOL shouldReleaseBuffer = NO;
                
                QGChangeFrameVideoCompositionInstruction *instruction = (QGChangeFrameVideoCompositionInstruction *)request.videoCompositionInstruction;
                AVVideoCompositionLayerInstruction *layerInstruction = instruction.layerInstructions.firstObject;
                                
                if (CMTIME_COMPARE_INLINE(request.compositionTime, ==, instruction.frameTime) && instruction.frameImage) {
                    /* 替换封面 */
                    resultPixels = [request.renderContext newPixelBuffer];
                    shouldReleaseBuffer = YES;                    
                    [self.renderingContext render:instruction.frameImage toCVPixelBuffer:resultPixels];
                } else {
                    resultPixels = [request sourceFrameByTrackID:layerInstruction.trackID];
                    /* 适配 iOS 8/9可能取出空帧, 导致合成失败 （iOS 8/9，视频剪辑纯图片视频必现） */
                    if (resultPixels == NULL) {
                        resultPixels = [request.renderContext newPixelBuffer];
                        shouldReleaseBuffer = YES;
                    }
                }
                
                if (instruction.watermarkImage) {
                    /* 添加水印 */
                    CIFilter *watermarkFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
                    CIImage *backgroundImage = [CIImage imageWithCVPixelBuffer:resultPixels];
                    CIImage *watermarkImage = instruction.watermarkImage;
                    
                    CGAffineTransform transform = CGAffineTransformMakeTranslation(instruction.watermarkPosition.x, backgroundImage.extent.size.height - watermarkImage.extent.size.height - instruction.watermarkPosition.y);
                    CIImage *transformedWatermarkImage = [watermarkImage imageByApplyingTransform:transform];
                    
                    [watermarkFilter setValue:backgroundImage forKey:kCIInputBackgroundImageKey];
                    [watermarkFilter setValue:transformedWatermarkImage forKey:kCIInputImageKey];
                    
                    if (shouldReleaseBuffer) {
                        CVPixelBufferRelease(resultPixels);
                        resultPixels = nil;
                    }
                    
                    resultPixels = [request.renderContext newPixelBuffer];
                    shouldReleaseBuffer = YES;
                    [self.renderingContext render:watermarkFilter.outputImage toCVPixelBuffer:resultPixels];
                }
                
                if (resultPixels) {
                    [request finishWithComposedVideoFrame:resultPixels];
                } else {
                    [request finishWithError:error];
                }
                
                if (shouldReleaseBuffer) {
                    CVPixelBufferRelease(resultPixels);
                }
            }
        });
    }
}

- (void)cancelAllPendingVideoCompositionRequests {
    // pending requests will call finishCancelledRequest, those already rendering will call finishWithComposedVideoFrame
    _shouldCancelAllRequests = YES;
    
    dispatch_barrier_async(_renderingQueue, ^() {
        // start accepting requests again
        self.shouldCancelAllRequests = NO;
    });
}

@end
