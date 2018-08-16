//
//  QGSimpleVideoPreviewView.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/13.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGSimpleVideoPreviewView.h"
#import <Masonry/Masonry.h>
#import "UIImage+QGImageBundle.h"

@interface QGSimpleVideoPreviewView ()

@property (nonatomic, strong) UIButton *playButton;

@end

@implementation QGSimpleVideoPreviewView

- (void)setup {
    [super setup];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image = image = [UIImage qg_imageNamed:@"mockup_preview_icon_play" bundleResourceName:@"QGCommonUILibrary" aClassInBundle:self.class];
    [_playButton setImage:image forState:UIControlStateNormal];
    
    [_playButton setImage:[UIImage new] forState:UIControlStateSelected];
    [_playButton setImage:[UIImage new] forState:UIControlStateHighlighted];
    [_playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:_playButton];
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)playButtonAction:(UIButton *)playButton {
    if (self.isPlaying) {
        [self pause];
    } else {
        [self play];
    }
}

#pragma mark - Control

- (void)play {
    [super play];
    _playButton.selected = YES;
}

- (void)pause {
    [super pause];
    _playButton.selected = NO;
}

#pragma mark - Setters

- (void)setHidePlayButton:(BOOL)hidePlayButton {
    _hidePlayButton = hidePlayButton;
    _playButton.hidden = hidePlayButton;
}

- (void)setPausedStatePlayButtonImage:(UIImage *)pausedStatePlayButtonImage {
    _pausedStatePlayButtonImage = pausedStatePlayButtonImage;
    [_playButton setImage:_pausedStatePlayButtonImage forState:UIControlStateNormal];
}

@end
