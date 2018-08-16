//
//  QGSimpleVideoPreviewView.h
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/13.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGVideoPreviewView.h"

/**
 可以通过点击播放按钮来暂停/播放视频的播放器
 */
@interface QGSimpleVideoPreviewView : QGVideoPreviewView

@property (nonatomic, assign) BOOL hidePlayButton;///< 是否隐藏播放按钮. 注意, 如果播放按钮被隐藏, 则无法暂停/播放视频.
@property (nonatomic, strong) UIImage *pausedStatePlayButtonImage;///< 暂停状态时播放按钮显示的图标

@end
