//
//  QGVideoRangeSelectView.m
//  QGTemplateCompositor_Example
//
//  Created by 宇园 on 2018/4/2.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGVideoRangeSelectView.h"
#import "QGVideoFrameCollectionViewCell.h"
#import "Masonry.h"
#import "AVAsset+QGCommon.h"
#import "UIImage+QGImageBundle.h"
#import "QGMacro.h"

static NSString *const kVideoFrameCellIdentifier = @"QGVideoFrameCollectionViewCell";

@interface QGVideoRangeSelectView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *rangeImageView;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *rightMaskView;
@property (weak, nonatomic) IBOutlet UIView *leftMaskView;

@end

@implementation QGVideoRangeSelectView

#pragma mark - Init & setup

// used when call -init or -initWithFrame:
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialateFromNib];
    }
    return self;
}

// used when init from xib or stroyboard
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialateFromNib];
    }
    return self;
}

- (void)initialateFromNib {
    /* 从xib文件中初始化子视图 */
    [[NSBundle bundleForClass:self.class] loadNibNamed:NSStringFromClass(self.class) owner:self options:nil];
    /* 将contentView添加为自己的子视图 */
    self.contentView.backgroundColor = QG_UIColorHex(0x1d1d1d);
    self.rightMaskView.backgroundColor = [QG_UIColorHex(0x1d1d1d) colorWithAlphaComponent:0.9];
    self.leftMaskView.backgroundColor = [QG_UIColorHex(0x1d1d1d) colorWithAlphaComponent:0.9];
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    /* setup */
    [self setup];
}

- (void)setup {
    // setup code
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(QGVideoFrameCollectionViewCell.class)
                                bundle:[NSBundle bundleForClass:QGVideoFrameCollectionViewCell.class]];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:kVideoFrameCellIdentifier];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    
    CGFloat left = (UIScreen.mainScreen.bounds.size.width - 158) / 2.0f;
    _collectionView.contentInset = UIEdgeInsetsMake(0, left, 0, left);
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(50, 50);
    
    self.selectedTimeRange = _selectedTimeRange;
    [self updateStartEndTimeLabels];
    
    UIImage *rangeImage = [UIImage qg_imageNamed:@"sign_widget_Fixed-length" bundleResourceName:@"QGCommonUILibrary" aClassInBundle:self.class];
    _rangeImageView.image = [rangeImage resizableImageWithCapInsets:UIEdgeInsetsMake(20.f, 20.f, 20.f, 20.f)];
}

- (void)updateStartEndTimeLabels {
    NSTimeInterval startTime = CMTimeGetSeconds(_selectedTimeRange.start);
    _startTimeLabel.text = [NSString stringWithFormat:@"%.0lf:%02d", startTime / 60, ((int)startTime) % 60];
    
    NSTimeInterval endTime = CMTimeGetSeconds(CMTimeRangeGetEnd(_selectedTimeRange));
    _endTimeLabel.text = [NSString stringWithFormat:@"%.0lf:%02d", endTime / 60, ((int)endTime) % 60];
}

- (NSTimeInterval)secondsPerItem {
    NSTimeInterval selectedDuration = CMTimeGetSeconds(_selectedTimeRange.duration);
    NSTimeInterval secondsPerItem = (selectedDuration / 3.5f);
    return secondsPerItem;
}

- (CGFloat)widthPerItem {
    return 50;
}

#pragma mark - UICollectionViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (_willBeginSelectingTimeRange) {
        _willBeginSelectingTimeRange();
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateSelectedTimeRangeWithScrollView:scrollView];
}

- (void)updateSelectedTimeRangeWithScrollView:(UIScrollView *)scrollView {
    CGFloat contentOffsetX = scrollView.contentOffset.x + scrollView.contentInset.left;
    CGFloat contentWidth = [self collectionView:_collectionView numberOfItemsInSection:0] * [self widthPerItem];
    
    if (contentOffsetX < 0) {
        contentOffsetX = 0;
    }
    
    CGFloat maxX = contentWidth - CGRectGetWidth(_rangeImageView.bounds);
    if (contentOffsetX > maxX) {
        contentOffsetX = maxX;
    }
    
    NSTimeInterval videoDuration = CMTimeGetSeconds(_videoAsset.duration);
    NSTimeInterval startTime = contentOffsetX / contentWidth * videoDuration;
    CMTimeScale timeScale = _selectedTimeRange.duration.timescale;
    _selectedTimeRange.start = CMTimeMake(startTime * timeScale, timeScale);
    
    [self updateStartEndTimeLabels];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (velocity.x == 0) {
        [self updateSelectedTimeRangeWithScrollView:scrollView];
        if (_selectedTimeRangeChanged) {
            _selectedTimeRangeChanged(_selectedTimeRange);
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateSelectedTimeRangeWithScrollView:scrollView];
    if (_selectedTimeRangeChanged) {
        _selectedTimeRangeChanged(_selectedTimeRange);
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSTimeInterval videoDuration = CMTimeGetSeconds(_videoAsset.duration);
    NSTimeInterval secondsPerItem = [self secondsPerItem];
    
    NSInteger number = ceil(videoDuration / secondsPerItem);
    return number;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QGVideoFrameCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoFrameCellIdentifier forIndexPath:indexPath];
    
    NSTimeInterval currentTime = indexPath.row * [self secondsPerItem];
    cell.image = [_videoAsset qg_imageAtTime:currentTime];
    
    return cell;
}

#pragma mark - Setters

- (void)setVideoAsset:(AVAsset *)videoAsset {
    _videoAsset = videoAsset;
    if (self.superview) {
        [_collectionView reloadData];
    }
    
    [self setNeedsLayout];
}

- (void)setSelectedTimeRange:(CMTimeRange)selectedTimeRange {
    _selectedTimeRange = selectedTimeRange;
    [self updateStartEndTimeLabels];
    
    if (self.superview) {
        [_collectionView reloadData];
    }
    
    [self setNeedsLayout];
}

#pragma mark - Layout Subviews

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_videoAsset == nil || CMTIME_COMPARE_INLINE(_selectedTimeRange.duration, ==, kCMTimeZero)) {
        return;
    }
    
    NSTimeInterval videoDuration = CMTimeGetSeconds(_videoAsset.duration);
    CGPoint offset = _collectionView.contentOffset;
    CGFloat contentWidth = [self collectionView:_collectionView numberOfItemsInSection:0] * [self widthPerItem];
    offset.x = (CMTimeGetSeconds(_selectedTimeRange.start) / videoDuration) * contentWidth;
    offset.x -= _collectionView.contentInset.left;
    
    if (isnan(offset.x) || isnan(offset.y)) {
        return;
    }
    
    _collectionView.contentOffset = offset;
}

@end
