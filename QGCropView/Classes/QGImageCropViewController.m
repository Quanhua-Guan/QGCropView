//
//  QGImageCropViewController.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/30.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGImageCropViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+QGImageBundle.h"
#import "UIImage+QGExtra.h"
#import "QGRotateView.h"
#import "QGMacro.h"

@interface QGImageCropViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet QGImageCropView *cropView;
@property (weak, nonatomic) IBOutlet UIImageView *maskImageView;
@property (weak, nonatomic) IBOutlet QGRotateView *rotateView;
@property (weak, nonatomic) IBOutlet UIView *bottomPlaceholderView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maskImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maskImageViewHeight;
@property (weak, nonatomic) IBOutlet UIView *cropOperationView;

@property (nonatomic, strong) UIColor *maskColor;

@end

@implementation QGImageCropViewController

#pragma mark - ViewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMaskColor];
    [self setupImageCropView];
    [self setupRotateView];
    [self setupMaskImageView];
    [self setupNavigationView];
}

#pragma mark - Setup

- (void)setupMaskColor {
    _maskColor = self.view.backgroundColor;
    _bottomPlaceholderView.backgroundColor = QG_UIColorHex(0x1d1d1d);
    if (_maskImage) {
        _maskColor = [_maskImage qg_opaqueColor];
    }
}

- (void)setupImageCropView {
    NSParameterAssert(_originImage);
    NSParameterAssert(_cropPixelSize.width > 0);
    NSParameterAssert(_cropPixelSize.height > 0);
    
    _cropOperationView.backgroundColor = QG_UIColorHex(0x1d1d1d);
    
    _cropView.cropPixelSize = _cropPixelSize;
    _cropView.originImage = _originImage;
    _cropView.maskColor = _maskColor;
    
    if (_cropSetting == nil) {
        _cropSetting = [QGCropSetting new];
    }
    [_cropView updateCropSetting:_cropSetting animate:NO adjust:NO];
    
    @weakify(self);
    _cropView.settingsChanged = ^(QGCropSetting *cropSetting, BOOL animate) {
        @strongify(self);
        self.rotateView.angle = (cropSetting.rotation / M_PI) * 180.0f;
    };
    _cropView.willStartCropping = ^{
        @strongify(self);
        [self willStartCropping];
    };
    _cropView.didEndCropping = ^{
        @strongify(self);
        [self didEndCropping];
    };
}

- (void)setupRotateView {
    @weakify(self);
    _rotateView.angle = _cropSetting.rotation / M_PI * 180.0f;
    _rotateView.angleChanged = ^(CGFloat newAngle, BOOL shouldAnimate) {
        @strongify(self);
        CGFloat radian = newAngle / 180.0f * M_PI;
        [self.cropView updateRotation:radian animate:shouldAnimate adjust:YES];
    };
    _rotateView.willStartChangingAngle = ^{
        @strongify(self);
        [self willStartCropping];
    };
    _rotateView.didEndChangingAngle = ^{
        @strongify(self);
        [self didEndCropping];
    };
}

- (void)setupMaskImageView {
    _maskImageView.image = _maskImage;
    
    if (!_maskImage) {
        return;
    }
    
    /* 遮罩图片视图布局 */
    CGSize cropViewSize = [self cropViewMaxSize];
    CGRect bounds = CGRectZero;
    bounds.size = cropViewSize;
    cropViewSize = AVMakeRectWithAspectRatioInsideRect(_cropPixelSize, bounds).size;
    _maskImageViewWidth.constant = cropViewSize.width;
    _maskImageViewHeight.constant = cropViewSize.height;
}

- (void)setupNavigationView {
    if (_cancelButtonImage == nil) {
        _cancelButtonImage = [UIImage qg_imageNamed:@"mockup_icon_close" bundleResourceName:@"QGCropView" aClassInBundle:self.class];
    }
    [_cancelButton setImage:_cancelButtonImage forState:UIControlStateNormal];
}

#pragma mark - CropView

- (CGSize)cropViewMaxSize {
    CGSize size = UIScreen.mainScreen.bounds.size;
    size.height = size.width;
    return size;
}

- (void)willStartCropping {
    if (self.maskImageView.alpha == 0.5f) {
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.maskImageView.alpha = 0.5f;
        self.cropView.maskColor = [self.maskColor colorWithAlphaComponent:0.5f];
    }];
}

- (void)didEndCropping {
    if (self.maskImageView.alpha == 1.0f) {
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        self.maskImageView.alpha = 1.0f;
        self.cropView.maskColor = self.maskColor;
    }];
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    
    _titleLabel.text = title;
}

- (void)setCancelButtonImage:(UIImage *)cancelButtonImage {
    _cancelButtonImage = cancelButtonImage;
    [_cancelButton setImage:_cancelButtonImage forState:UIControlStateNormal];
}

- (void)setDoneButtonImage:(UIImage *)doneButtonImage {
    _doneButtonImage = doneButtonImage;
//    [_doneButton setImage:_doneButtonImage forState:UIControlStateNormal];
}

#pragma mark - IBActions

- (void)closeAction {
    if (self.navigationController.topViewController == self) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelButtonAction:(UIButton *)sender {
    if (_cancelBlock) {
        _cancelBlock();
    } else {
        [self closeAction];
    }
}

- (IBAction)doneButtonAction:(UIButton *)sender {
    if (_doneWithCroppedImageBlock) {
        UIImage *croppedImage = _cropView.croppedImage;
        _doneWithCroppedImageBlock(croppedImage);
    }
    
    if (_doneWithCropSettingBlock) {
        _doneWithCropSettingBlock(_cropView.cropSetting, _cropPixelSize);
    }
        
    if (!_dontCloseWhenDone) {
        [self closeAction];
    }
}

@end
