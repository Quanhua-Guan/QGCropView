//
//  QGVideoPreviewView.m
//  QGCropView
//
//  Created by 宇园 on 2017/12/19.
//  Copyright © 2017年 CQMH. All rights reserved.
//

#import "QGVideoPreviewView.h"

@interface QGVideoPreviewView ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) id timeObserver;

@end

@implementation QGVideoPreviewView

#pragma mark - LayerClass

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

#pragma mark - Init & setup

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup {
    _loop = YES;
}

#pragma mark - Setters

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem) {
        [NSNotificationCenter.defaultCenter removeObserver:self];
    }
    
    _playerItem = playerItem;
    [self preparePlayer];
}

- (void)setVideoURL:(NSURL *)videoURL {
    if (videoURL) {
        _videoURL = videoURL;
        AVURLAsset *videoAsset = [AVURLAsset assetWithURL:videoURL];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:videoAsset
                                          automaticallyLoadedAssetKeys:@[@"tracks", @"duration"]];
        if (playerItem) {
            self.playerItem = playerItem;
        }
    }
}

- (void)setVolume:(CGFloat)volume {
    _player.volume = volume;
}

- (CGFloat)volume {
    return _player.volume;
}

#pragma mark - Getters

- (CMTime)currentTime {
    return _player.currentTime;
}

- (CMTime)duration {
    return self.playerItem.duration;
}

#pragma mark - Play & pause

- (void)preparePlayer {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(playerItemDidPlayToEndTime:)
                                               name:AVPlayerItemDidPlayToEndTimeNotification
                                             object:_playerItem];
    if (_player == nil) {
        self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    } else {
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
    [self.player seekToTime:kCMTimeZero];
    
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    [playerLayer setPlayer:self.player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification {
    if (_videoDidPlayToEndTimeActionBlock) {
        _videoDidPlayToEndTimeActionBlock();
        return;
    }
    
    [self.player seekToTime:kCMTimeZero];
    if (_loop) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)seekToTime:(CMTime)time {
    [self.player seekToTime:time];
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (BOOL)isPlaying {
    return self.player.rate != 0;
}

#pragma mark - 额外播放图层(用于多个窗口同时播放一个视频)

- (AVPlayerLayer *)createAnotherPlayerLayer {
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    return playerLayer;
}

#pragma mark - 计时器

- (void)resetPeriodicTimerInterval:(CMTime)interval usingBlock:(void (^)(CMTime time))block {
    [self removePeriodicTimerIfHasOne];
    _timeObserver = [_player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:block];
}

- (void)removePeriodicTimerIfHasOne {
    if (_timeObserver) {
        [_player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [self removePeriodicTimerIfHasOne];
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

@end

