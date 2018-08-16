//
//  QGAVideoNAudioPreviewView.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/14.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGAVideoNAudioPreviewView.h"
#import "QGAVideoNAudioComposer.h"

@interface QGAVideoNAudioPreviewView ()

@property (nonatomic, strong) QGAVideoNAudioComposer *composer;

@end

@implementation QGAVideoNAudioPreviewView

- (instancetype)initWithVideoAsset:(AVAsset *)videoAsset audioAssets:(NSArray<AVAsset *> *)audioAssets {    
    self = [super init];
    if (self) {
        [self setupPlayViewWithVideoAsset:videoAsset audioAssets:audioAssets];
    }
    
    return self;
}

- (void)setupPlayViewWithVideoAsset:(AVAsset *)videoAsset audioAssets:(NSArray<AVAsset *> *)audioAssets {
    [self.composer resetVideoAsset:videoAsset audioAssets:audioAssets];
    self.playerItem = [self.composer playerItem];    
}

#pragma mark - 控制

- (void)play {
    if (self.isPlaying) {
        return;
    }
    [super play];
}

- (void)pause {
    if (!self.isPlaying) {
        return;
    }
    [super pause];
}

#pragma mark - Setters

- (void)setWatermarkImage:(UIImage *)watermarkImage {
    _watermarkImage = watermarkImage;
    self.composer.watermarkImage = _watermarkImage;
}

- (void)setWatermarkPosition:(CGPoint)watermarkPosition {
    _watermarkPosition = watermarkPosition;
    self.composer.watermarkPosition = _watermarkPosition;
}

#pragma mark - Getters

- (AVAsset *)videoAsset {
    return self.composer.videoAsset;
}

- (NSArray<AVAsset *> *)audioAssets {
    return self.composer.audioAssets;
}

- (QGAVideoNAudioComposer *)composer {
    if (_composer == nil) {
        _composer = [QGAVideoNAudioComposer new];
        _composer.watermarkImage = _watermarkImage;
        _composer.watermarkPosition = _watermarkPosition;
    }
    return _composer;
}

#pragma mark - 音量

- (void)setVolume:(CGFloat)volume forAsset:(AVAsset *)audioAsset {
    [self setVolume:volume forAssets:@[audioAsset]];
}

- (void)setVolume:(CGFloat)volume forAssets:(NSArray<AVAsset *> *)audioAssets {
    [self.composer setVolume:volume forAssets:audioAssets];
    self.playerItem.audioMix = self.composer.audioMix;
}

#pragma mark - 音频轨道操作

- (void)resetAudioAssets:(NSArray<AVAsset *> *)audioAssets {
    [self resetVideoAsset:self.videoAsset audioAssets:audioAssets];
}

- (void)resetVideoAsset:(AVAsset *)videoAsset audioAssets:(NSArray<AVAsset *> *)audioAssets {
    /* 暂停播放 */
    [self pause];
    
    /* 更新视频轨道和音频轨道 + 重置视频轨道和音频轨道 */
    [self setupPlayViewWithVideoAsset:videoAsset audioAssets:audioAssets];
}

#pragma mark - Dealloc

- (void)dealloc {
    
}

#pragma mark - 视图层级

- (void)didMoveToSuperview {
    if (self.superview == nil) {
        [self pause];
    }
}

@end
