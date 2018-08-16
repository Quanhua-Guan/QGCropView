//
//  QGRotateView.m
//
//  Created by 宇园 on 15/12/29.
//  Copyright © 2015年 CQMH. All rights reserved.
//

#import "QGRotateView.h"
#import "QGAngleSlider.h"
#import "UIImage+QGImageBundle.h"
#import "QGMacro.h"
#import "Masonry.h"


@interface QGRotateView ()

@property (nonatomic, strong) QGAngleSlider *slider;///< 刻度视图
@property (nonatomic, strong) UIButton *rightAngleAdjustButton;///< 修正到顺时针旋转90°倍数

@end

@implementation QGRotateView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.backgroundColor = QG_UIColorHex(0x1d1d1d);
    [self rightAngleAdjustButton];
    [self slider];
}

#pragma mark - Actions

- (void)rightAngleAdjustButtonAction:(UIButton *)sender {
    CGFloat angle = _slider.angle;
    angle = (floor(angle / 90.0f) + 1.0f) * 90.0f;
    _slider.angle = angle;
    _angleChanged(angle, YES);
    _angleChanged(_slider.angle, NO);
}

#pragma mark - Setters / Getters

- (void)setAngle:(CGFloat)angle {
    _slider.angle = angle;
}

- (CGFloat)angle {
    return _slider.angle;
}

- (void)setAngleChanged:(void (^)(CGFloat, BOOL))angleChanged {
    _angleChanged = [angleChanged copy];
    @weakify(self);
    _slider.angleChanged = ^(CGFloat newAngle, BOOL shouldAnimate) {
        @strongify(self);
        if (self.angleChanged) {
            self.angleChanged(newAngle, shouldAnimate);
        }
    };
}

- (void)setWillStartChangingAngle:(void (^)(void))willStartChangingAngle {
    _slider.willStartChangingAngle = willStartChangingAngle;
}

- (void (^)(void))willStartChangingAngle {
    return _slider.willStartChangingAngle;
}

- (void)setDidEndChangingAngle:(void (^)(void))didEndChangingAngle {
    _slider.didEndChangingAngle = didEndChangingAngle;
}

- (void (^)(void))didEndChangingAngle {
    return _slider.didEndChangingAngle;
}

- (QGAngleSlider *)slider {
    if (_slider == nil) {
        self.slider = [[QGAngleSlider alloc] initWithFrame:self.bounds];
        [self addSubview:_slider];
        
        [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(10);
            make.right.equalTo(self.rightAngleAdjustButton.mas_left).offset(-10.0f);
            make.height.mas_equalTo(50.0f);
            make.centerY.equalTo(self.rightAngleAdjustButton.mas_centerY);
        }];
    }
    return _slider;
}

#pragma mark - View Getters

- (UIButton *)rightAngleAdjustButton {
    if (_rightAngleAdjustButton == nil) {
        self.rightAngleAdjustButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *rotateRightImage = _rotateRightImage;
        if (rotateRightImage == nil) {
            rotateRightImage = [UIImage qg_imageNamed:@"mockup_icon_edit_rotate" bundleResourceName:@"QGCropView" aClassInBundle:self.class];
        }
        [_rightAngleAdjustButton setImage:rotateRightImage forState:UIControlStateNormal];
        
        [_rightAngleAdjustButton addTarget:self action:@selector(rightAngleAdjustButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightAngleAdjustButton];
        
        [_rightAngleAdjustButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-10.0f);
            make.size.mas_equalTo(CGSizeMake(34.0f, 34.0f));
            make.bottom.equalTo(self.mas_bottom).offset(-13.0f);
        }];
    }
    return _rightAngleAdjustButton;
}

@end
