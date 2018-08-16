//
//  QGVideoExporter.h
//  AFNetworking
//
//  Created by 宇园 on 2018/4/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AVAsset, AVAudioMix, AVVideoComposition;

@interface QGVideoExporter : NSObject

- (instancetype)initWithAsset:(AVAsset *)asset audioMix:(AVAudioMix *_Nullable)audioMix videoComposition:(AVVideoComposition *_Nullable)videoComposition;

/**
 取消视频导出操作
 */
- (void)cancelExport;

/**
 导出视频
 
 @param videoOutputPath 视频导出后写入的路径
 @param progress 导出进度回调, 返回进度[0, 1.0]
 @param canceled 取消导出操作的回调
 @param finished 导出操作完成, error为nil, 则导出成功, 否则导出失败.
 */
- (void)exportVideoToPath:(NSString *)videoOutputPath
                 progress:(void(^_Nullable)(CGFloat progress))progress
                 canceled:(void (^_Nullable)(void))canceled
                 finished:(void(^_Nullable)(NSError *error))finished;

@end

NS_ASSUME_NONNULL_END
