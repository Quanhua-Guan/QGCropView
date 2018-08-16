//
//  QGVideoFrameCollectionViewCell.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/4/2.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGVideoFrameCollectionViewCell.h"

@interface QGVideoFrameCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation QGVideoFrameCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    _imageView.image = image;
}

@end
