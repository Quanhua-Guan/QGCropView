//
//  QGVideoCropViewController.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/4/2.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGVideoCropViewController.h"
#import "QGVideoCropView.h"
#import "QGRotateView.h"
#import "QGVideoRangeSelectView.h"
#import "UIImage+QGImageBundle.h"
#import "QGMacro.h"
#import "SVProgressHUD.h"
#import "UIImage+QGExtra.h"

@interface QGVideoCropViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet QGVideoCropView *cropView;
@property (weak, nonatomic) IBOutlet UIImageView *maskImageView;
@property (weak, nonatomic) IBOutlet QGRotateView *rotateView;
@property (weak, nonatomic) IBOutlet QGVideoRangeSelectView *rangeSelectView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maskImageViewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *maskImageViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rotateViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navigationViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rangeSelectViewHeight;
@property (weak, nonatomic) IBOutlet UIView *cropOperationView;

@property (nonatomic, strong) UIColor *maskColor;

@end

@implementation QGVideoCropViewController

#pragma mark - ViewDidLoad

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMaskColor];
    [self setupCropView];
    [self setupRotateView];
    [self setupMaskImageView];
    [self setupRangeSelectView];
    [self setupNavigationView];
}

#pragma mark - View Appear/Disappear

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_cropView play];    
    _rangeSelectView.selectedTimeRange = _selectedTimeRange;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_cropView pause];
}

#pragma mark - Setup

- (void)setupMaskColor {
    _maskColor = self.view.backgroundColor;
    if (_maskImage) {
        _maskColor = [_maskImage qg_opaqueColor];
    }
}

- (void)setupCropView {
    NSParameterAssert(_originVideoAsset);
    NSParameterAssert(_cropPixelSize.width > 0);
    NSParameterAssert(_cropPixelSize.height > 0);
    
    _cropOperationView.backgroundColor = QG_UIColorHex(0x1d1d1d);
    
    _cropView.cropPixelSize = _cropPixelSize;
    _cropView.originVideoAsset = _originVideoAsset;
    _cropView.maskColor = _maskColor;
    _cropView.cropTimeRange = self.selectedTimeRange;
    
    if (_cropSetting == nil) {
        _cropSetting = [QGCropSetting new];
    }
    [_cropView updateCropSetting:_cropSetting animate:NO adjust:NO];
    
    @weakify(self);
    _cropView.settingsChanged = ^(QGCropSetting *cropSetting, BOOL animate) {
        @strongify(self);
        self.cropSetting = cropSetting;
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

- (void)setupRangeSelectView {
    _rangeSelectView.videoAsset= _originVideoAsset;
    _rangeSelectView.selectedTimeRange = _selectedTimeRange;
    
    @weakify(self);
    _rangeSelectView.willBeginSelectingTimeRange = ^{
        @strongify(self);
        [self.cropView pause];
    };
    _rangeSelectView.selectedTimeRangeChanged = ^(CMTimeRange selectedTimeRange) {
        @strongify(self);
        self.selectedTimeRange = selectedTimeRange;
        self.cropView.cropTimeRange = selectedTimeRange;
        [self.cropView play];
    };
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
    if (_doneWithCropSettingBlock) {
        _doneWithCropSettingBlock(_cropView.cropSetting, _cropPixelSize, _selectedTimeRange);
    }
    
    /* 使用局部变量暂存, 防止[self释放, 导致无法找到对应的Block] */
    void (^willCropVideoBlock)(void) = [_willCropVideoBlock copy];
    void (^cropVideoProgressBlock)(CGFloat progress) = [_cropVideoProgressBlock copy];
    void (^cropVideoCancelBlock)(void) = [_cropVideoCancelBlock copy];
    void (^cropVideoFinishedBlock)(NSError *_Nullable error, NSString *croppedVideoPath) = [_cropVideoFinishedBlock copy];
    
    if (cropVideoFinishedBlock) {
        NSString *croppedVideoPath = [QGVideoCropViewController tempFilePathWithSuffix:@".mp4"];
        BOOL useDefaultHUD = (willCropVideoBlock == nil);
        
        if (useDefaultHUD) {
            [SVProgressHUD showProgress:0 status:@"正在裁剪..."];
        } else {
            willCropVideoBlock();
        }
        
        [self.cropView exportVideoToPath:croppedVideoPath preferredFPS:self.preferredFPS progress:^(CGFloat progress) {
            if (useDefaultHUD) {
                [SVProgressHUD showProgress:progress status:@"正在裁剪..."];
            } else {
                if (cropVideoProgressBlock) {
                    cropVideoProgressBlock(progress);
                }
            }
        } canceled:^{
            if (useDefaultHUD) {
                [SVProgressHUD dismiss];
            } else {
                if (cropVideoCancelBlock) {
                    cropVideoCancelBlock();
                }
            }
        } finished:^(NSError *_Nullable error) {
            if (error) {
                if (useDefaultHUD) {
                    [SVProgressHUD showErrorWithStatus:@"裁剪失败啦"];
                }
            } else {
                if (useDefaultHUD) {
                    [SVProgressHUD showSuccessWithStatus:@"裁剪成功"];
                }
            }
            
            cropVideoFinishedBlock(error, croppedVideoPath);
        }];
    }
    
    if (!_dontCloseWhenDone) {
        [self closeAction];
    }
}

#pragma mark - Utilies

+ (NSString *)tempFilePathWithSuffix:(NSString *)suffix
{
    NSString *tempDir = NSTemporaryDirectory();
    NSString *fileName = [self uuid];
    return [tempDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)uuid {
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

@end
