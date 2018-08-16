//
//  QGTestCropViewController.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/3/26.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGTestCropViewController.h"
#import "QGImageCropView.h"
#import "QGMacro.h"

@interface QGTestCropViewController ()
@property (weak, nonatomic) IBOutlet QGCropView *cropView;
@property (weak, nonatomic) IBOutlet QGCropView *cropView2;
@property (weak, nonatomic) IBOutlet QGImageCropView *imageCropView;
@property (weak, nonatomic) IBOutlet UIImageView *croppedImageView;

@end

@implementation QGTestCropViewController

- (void)viewDidLoad {    
    [super viewDidLoad];
    
    _cropView.hidden = _hideCropView;
    _cropView2.hidden = _hideCropView;
    
    UIImage *testImage = [UIImage imageNamed:@"test_crop.jpg"];
    CGSize imagePixelSize = testImage.size;
    imagePixelSize.width *= testImage.scale;
    imagePixelSize.height *= testImage.scale;
    
    // 测试视图
    UIImageView *imageView = [UIImageView new];
    imageView.image = testImage;
    
    _cropView.contentPixelSize = imagePixelSize;
    _cropView.cropPixelSize = CGSizeMake(250, 50);
    _cropView.minimalInset = UIEdgeInsetsMake(20, 20, 20, 20);
    
    [_cropView resetContent:imageView];
    
    @weakify(self);
    _cropView.settingsChanged = ^(QGCropSetting *setting, BOOL animate) {
        @strongify(self);
        [self.cropView2 updateCropSetting:setting animate:animate adjust:NO];
    };
    
    // 测试视图2
    UIImageView *imageView2 = [UIImageView new];
    imageView2.image = testImage;
    
    _cropView2.contentPixelSize = imagePixelSize;
    _cropView2.cropPixelSize = CGSizeMake(250, 50);
    
    [_cropView2 resetContent:imageView2];
    
    // 测试视图3
    _imageCropView.originImage = testImage;
    _imageCropView.cropPixelSize = CGSizeMake(500, 500);
}

- (IBAction)closeButtonAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cropImage:(id)sender {
    [self.view sendSubviewToBack:_imageCropView];
    UIImage *image = _imageCropView.croppedImage;
    _croppedImageView.image = image;
}

@end
