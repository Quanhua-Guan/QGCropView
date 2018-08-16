//
//  AngleSlider.m
//  QGCropView
//
//  Created by 宇园 on 2018/4/1.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGAngleSlider.h"
#import "UIImage+QGImageBundle.h"
#import "UIImage+QGExtra.h"
#import "Masonry.h"
#import "QGMacro.h"


@interface QGAngleSlider ()

@property (nonatomic, strong) UISlider *slider;///< 滑块
@property (nonatomic, strong) UIView *backgroundTrackView;///< 读数条背景
@property (nonatomic, strong) UIView *frontTrackView;///< 读数条前景

@property (nonatomic, strong) UIView *degreeContainerView;///< 标注刻度视图容器
@property (nonatomic, strong) NSMutableArray<UIView *> *degreeScaleViews;///< 刻度线
@property (nonatomic, strong) NSMutableArray<UILabel *> *degreeReadingLabels;///< 刻度标注

@property (nonatomic, assign) BOOL sliding;

@end

@implementation QGAngleSlider

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
    [self degreeContainerView];
    [self degreeScaleViews];
    [self degreeReadingLabels];
    [self backgroundTrackView];
    [self frontTrackView];
    [self slider];
}

#pragma mark - Layouts

- (void)layoutSubviews {
    CGFloat value = _slider.value;
    value = (value - _slider.minimumValue) / (_slider.maximumValue - _slider.minimumValue);
    CGFloat sliderThumbCenterX = value * (self.bounds.size.width - 25) + 12.5f;
    [_frontTrackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(2);
        make.centerY.equalTo(self);
        if (self.slider.value < 0) {
            make.left.mas_equalTo(sliderThumbCenterX);
            make.right.mas_equalTo(-self.bounds.size.width / 2);
        } else {
            make.left.mas_equalTo(self.bounds.size.width / 2);
            make.right.mas_equalTo(sliderThumbCenterX - self.bounds.size.width);
        }
    }];
    
    for (int index = 0; index < _degreeScaleViews.count; index++) {
        UIView *lineView = _degreeScaleViews[index];
        CGRect frame = CGRectMake(0, (self.bounds.size.height - 9) / 2.0f, 1, 4.5);
        if (lineView.tag == 2) {
            frame = CGRectMake(0, (self.bounds.size.height - 9) / 2.0f, 1, 9);
        }
        frame.origin.x += (self.bounds.size.width - 25) / (_degreeScaleViews.count - 1) * lineView.tag + 12.5f - 0.5f;
        
        [lineView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.degreeContainerView).with.offset(frame.origin.x);
            make.top.equalTo(self.degreeContainerView).with.offset(frame.origin.y);
            make.size.mas_equalTo(frame.size);
        }];
        
        UILabel *degreeLabel = _degreeReadingLabels[index];
        CGSize size = CGSizeMake(30, 9);
        [degreeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(lineView);
            make.bottom.equalTo(lineView.mas_top).offset(-8);
            make.size.mas_equalTo(size);
        }];
    }
    
    [super layoutSubviews];
}

#pragma mark - Setters/Getters

- (void)setAngle:(CGFloat)angle {
    /* 将角度限制在 -180~180 之间 */
    CGFloat sign = 1;
    CGFloat angleValue = angle;
    if (angle < 0) {
        sign = -1;
        angleValue = -angle;
    }
    angleValue = fmod(angleValue, 360.0f);
    if (angleValue > 180.0f) {
        angleValue = -(180.0f - (angleValue - 180.0f));
    }
    angleValue = angleValue * sign;
    
    /* 设置角度 */
    _slider.value = angleValue;
    [self setNeedsLayout];
}

- (CGFloat)angle {
    return _slider.value;
}

- (UISlider *)slider {
    if (_slider == nil) {
        CGRect frame = self.bounds;
        frame.size.height = 28.0f;
        self.slider = [[UISlider alloc] initWithFrame:frame];
        _slider.minimumValue = -180.0f;
        _slider.maximumValue = 180.0f;
        _slider.value = 0.0f;
        _slider.maximumTrackTintColor = [UIColor clearColor];
        _slider.minimumTrackTintColor = [UIColor clearColor];
        /**
         *  修改在iOS8以及一下版本中不显示原图片
         */
        if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_8_4) {
            CGFloat scale = [[UIScreen mainScreen] scale];
            UIImage *image = [UIImage qg_imageWithColor:[UIColor clearColor] andSize:CGSizeMake(4.0f * scale, 4.0f * scale)];
            [_slider setMaximumTrackImage:image forState:UIControlStateNormal];
            [_slider setMinimumTrackImage:image forState:UIControlStateNormal];
        }
        
        UIImage *thumbImage = _thumbImage;
        if (thumbImage == nil) {
            thumbImage = [UIImage qg_imageNamed:@"widget_axis_circular" bundleResourceName:@"QGCropView" aClassInBundle:self.class];
        }
        [_slider setThumbImage:thumbImage forState:UIControlStateNormal];
        
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_slider addTarget:self action:@selector(sliderTouchDownAction:) forControlEvents:UIControlEventTouchDown];
        [_slider addTarget:self action:@selector(sliderTouchUpAction:) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(sliderTouchUpAction:) forControlEvents:UIControlEventTouchUpOutside];
        [_slider addTarget:self action:@selector(sliderTouchUpAction:) forControlEvents:UIControlEventTouchCancel];
        [self addSubview:_slider];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [_slider addGestureRecognizer:tapGesture];
        
        [_slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).with.offset(10);
            make.right.equalTo(self.mas_right).with.offset(-10);
            make.centerY.equalTo(self.mas_centerY).with.offset(0);
            make.height.mas_equalTo(28.0f);
        }];
    }
    return _slider;
}

- (UIView *)degreeContainerView {
    if (_degreeContainerView == nil) {
        self.degreeContainerView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:_degreeContainerView];
        
        [_degreeContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(UIEdgeInsetsZero);
        }];
    }
    return _degreeContainerView;
}

- (NSMutableArray<UIView *> *)degreeScaleViews {
    if (_degreeScaleViews == nil) {
        self.degreeScaleViews = [NSMutableArray array];
        CGRect frame = CGRectZero;
        for (NSUInteger index = 0; index < 5; index++) {
            UIView *lineView = [[UIView alloc] initWithFrame:frame];
            lineView.backgroundColor = QG_UIColorHex(0x222b31);
            lineView.alpha = 1.0f;
            lineView.tag = index;
            [self.degreeContainerView addSubview:lineView];
            [_degreeScaleViews addObject:lineView];
        }
    }
    return _degreeScaleViews;
}

- (NSMutableArray<UILabel *> *)degreeReadingLabels {
    if (_degreeReadingLabels == nil) {
        _degreeReadingLabels = [NSMutableArray arrayWithCapacity:5];
        CGRect frame = CGRectMake(0.0f, 0.0f, 30.0f, 9.0f);
        NSArray<NSString *> *degreeTexts = @[@"-180°", @"-90°", @"0°", @"90°", @"180°"];
        int tag = 0;
        for (NSString *degreeText in degreeTexts) {
            UILabel *degreeLabel = [[UILabel alloc] initWithFrame:frame];
            degreeLabel.font = [UIFont systemFontOfSize:10];
            degreeLabel.textColor = QG_UIColorHex(0x40494f);
            degreeLabel.textAlignment = NSTextAlignmentCenter;
            degreeLabel.text = degreeText;
            degreeLabel.tag = tag;
            tag += 1;
            [self.degreeContainerView addSubview:degreeLabel];
            [_degreeReadingLabels addObject:degreeLabel];
        }
    }
    return _degreeReadingLabels;
}

- (UIView *)backgroundTrackView {
    if (_backgroundTrackView == nil) {
        _backgroundTrackView = [UIView new];
        _backgroundTrackView.backgroundColor = QG_UIColorHex(0x222b31);
        [self addSubview:_backgroundTrackView];
        
        [_backgroundTrackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(12);
            make.right.equalTo(self.mas_right).offset(-12);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(2);
        }];
    }
    return _backgroundTrackView;
}

- (UIView *)frontTrackView {
    if (_frontTrackView == nil) {
        _frontTrackView = [UIView new];
        _frontTrackView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_frontTrackView];
    }
    return _frontTrackView;
}

#pragma mark - Action

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if (_sliding) {
        return;
    }
    
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGFloat locationX = [recognizer locationInView:_slider].x;
        if (locationX < (_degreeScaleViews[0].center.x + _degreeScaleViews[1].center.x) / 2) {
            _slider.value = _slider.minimumValue;
        } else if (locationX < (_degreeScaleViews[1].center.x + _degreeScaleViews[2].center.x) / 2) {
            _slider.value = _slider.minimumValue / 2.0f;
        } else if (locationX < (_degreeScaleViews[2].center.x + _degreeScaleViews[3].center.x) / 2) {
            _slider.value = (_slider.minimumValue + _slider.maximumValue) / 2.0f;
        } else if (locationX < (_degreeScaleViews[3].center.x + _degreeScaleViews[4].center.x) / 2) {
            _slider.value = (_slider.maximumValue) / 2.0f;
        } else {
            _slider.value = _slider.maximumValue;
        }
        
        [self angleChange:_slider.value withAnimate:YES];
    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    _sliding = YES;
    [self angleChange:slider.value withAnimate:NO];
}

- (void)sliderTouchDownAction:(UISlider *)slider {
    if (_willStartChangingAngle) {
        _willStartChangingAngle();
    }
}

- (void)sliderTouchUpAction:(UISlider *)slider {
    if (_didEndChangingAngle) {
        _didEndChangingAngle();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.sliding = NO;
    });
}

#pragma mark - Select an Angle

- (void)angleChange:(CGFloat) newAngle withAnimate:(BOOL)animate {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (_angleChanged) {
        _angleChanged(newAngle, animate);
    }
}

@end
