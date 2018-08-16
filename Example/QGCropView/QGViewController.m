//
//  QGViewController.m
//  QGCropView
//
//  Created by xinmuheart@163.com on 08/16/2018.
//  Copyright (c) 2018 xinmuheart@163.com. All rights reserved.
//

#import "QGViewController.h"
#import "QGTestCropViewController.h"
#import "QGImageCropViewController.h"
#import "QGVideoCropViewController.h"
#import "QGCropView.h"
#import "QGMacro.h"

@interface QGViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation QGViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - IBAction

- (IBAction)goImageCropTestingPage:(UIButton *)sender {
    QGTestCropViewController *viewController = [QGTestCropViewController new];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)goImageCropTestingPage2:(UIButton *)sender {
    QGTestCropViewController *viewController = [QGTestCropViewController new];
    viewController.hideCropView = YES;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)goImageCropTestingPage3:(UIButton *)sender {
    // 图片裁剪页
    UIImage *originImage = [UIImage imageNamed:@"test_crop.jpg"];
    CGSize imagePixelSize = originImage.size;
    imagePixelSize.width *= originImage.scale;
    imagePixelSize.height *= originImage.scale;
    
    QGImageCropViewController *imageCropViewController = [QGImageCropViewController new];
    imageCropViewController.cropPixelSize = CGSizeMake(500, 500);// 500x500 像素
    imageCropViewController.originImage = originImage;
    
    @weakify(self);
    imageCropViewController.doneWithCropSettingBlock = ^(QGCropSetting *cropSetting, CGSize cropPixelSize) {
        //@strongify(self);
    };
    imageCropViewController.doneWithCroppedImageBlock = ^(UIImage *cropedImage) {
        @strongify(self);
        self.imageView.image = cropedImage;
    };
    
    [self presentViewController:imageCropViewController animated:YES completion:nil];
}

- (IBAction)goImageCropTestingPage4:(UIButton *)sender {
    // 视频裁剪页
}

@end
