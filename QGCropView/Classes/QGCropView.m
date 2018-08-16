//
//  QGCropView.m
//  QGCropView
//
//  Created by 宇园 on 2018/3/26.
//  Copyright © 2018年 CQMH. All rights reserved.
//

#import "QGCropView.h"
#import <AVFoundation/AVUtilities.h>

#pragma mark - QGCropRotate/Zooming/Translate/ContentView

@interface QGCropRotateView : UIView
@end
@implementation QGCropRotateView
@end

@interface QGCropZoomingView : UIView
@end
@implementation QGCropZoomingView
@end

@interface QGCropTranslateView : UIView
@end
@implementation QGCropTranslateView
@end

@interface QGCropContentView : UIView
@end
@implementation QGCropContentView
@end

#pragma mark - QGCropSetting

@interface QGCropSetting ()

@end

@implementation QGCropSetting

- (instancetype)init
{
    self = [super init];
    if (self) {
        _rotation = 0;
        _scale = 1;
        _translation = CGPointZero;
        _cropSize = CGSizeMake(1, 1);
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    QGCropSetting *setting = [self.class new];
    setting.rotation = _rotation;
    setting.scale = _scale;
    setting.translation = _translation;
    setting.cropSize = _cropSize;
    return setting;
}

- (CGPoint)relativeTranslation {
    NSAssert(_cropSize.width > 0, @"Crop size width must > 0!");
    NSAssert(_cropSize.height > 0, @"Crop size height must > 0!");
    return CGPointMake(_translation.x / _cropSize.width, _translation.y / _cropSize.height);
}

- (void)setCropSize:(CGSize)cropSize {
    /* 限制cropSize不为0 */
    if (cropSize.width <= 0) {
        cropSize.width = 1;
    }
    if (cropSize.height <= 0) {
        cropSize.height = 1;
    }
    
    _cropSize = cropSize;
}

@end

#pragma mark - QGCropView

@interface QGCropView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *viewportView;///< 视窗视图, 矩形遮罩视图, 最终截取图片包含在该区域内.
@property (nonatomic, strong) QGCropRotateView *rotateView;///< 负责旋转的视图
@property (nonatomic, strong) QGCropZoomingView *zoomingView;///< 负责缩放的视图
@property (nonatomic, strong) QGCropTranslateView *translationView;///< 负责平移的视图
@property (nonatomic, strong) QGCropContentView *contentView;///< 展示内容的视图, 被裁剪的视图将被添加到该视图.
@property (nonatomic, strong) UIView *content;///< 内容视图, 由外部传入. 可能是图片, 视频, 视图, 或其他可视对象

@property (nonatomic, copy) QGCropSetting *cropSetting;///< 当前的旋转/缩放/平移操作参数

@end

@interface QGCropView () ///< 遮罩

@property (nonatomic, strong) UIView *topMaskView;///< 视窗视图顶部遮罩
@property (nonatomic, strong) UIView *leftMaskView;///< 视窗视图左部遮罩
@property (nonatomic, strong) UIView *bottomMaskView;///< 视窗视图底部遮罩
@property (nonatomic, strong) UIView *rightMaskView;///< 视窗视图右部遮罩

@end

@interface QGCropView () ///< 手势

@property (nonatomic, strong) UIRotationGestureRecognizer *rotationGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@end

@implementation QGCropView

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
    /* 视图层级
     CropView
        |--RotateView
        |   |--ZoomingView
        |       |--TranslateView
        |           |--ContentView
        |--ViewportView
        |--TopMakView
        |--LeftMakView
        |--BottomMakView
        |--RightMakView
     */
    _rotateView = [QGCropRotateView new];
    [self addSubview:_rotateView];
    
    _zoomingView = [QGCropZoomingView new];
    [_rotateView addSubview:_zoomingView];
    
    _translationView = [QGCropTranslateView new];
    [_zoomingView addSubview:_translationView];
    
    _contentView = [QGCropContentView new];
    [_translationView addSubview:_contentView];
    
    _viewportView = [UIView new];
    _viewportView.backgroundColor = [UIColor clearColor];
    [self addSubview:_viewportView];
    
    /* 遮罩视图们 */
    _topMaskView = [UIView new];
    _leftMaskView = [UIView new];
    _bottomMaskView = [UIView new];
    _rightMaskView = [UIView new];
    for (UIView *view in @[_topMaskView, _leftMaskView, _bottomMaskView, _rightMaskView]) {
        view.backgroundColor = (_maskColor ?: [UIColor colorWithWhite:0 alpha:0.25f]);
        view.hidden = _hideMask;
        [self addSubview:view];
    }
    
    /* 手势 */
    _rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGestureHandler:)];
    _rotationGesture.delegate = self;
    [self addGestureRecognizer:_rotationGesture];
    _rotationGesture.enabled = !_disableRotation;
    
    _pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureHandler:)];
    _pinchGesture.delegate = self;
    [self addGestureRecognizer:_pinchGesture];
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    _panGesture.delegate = self;
    [self addGestureRecognizer:_panGesture];
    
    /* 遮罩相关 */
    self.clipsToBounds = YES;
    
    /* 初始配置 */
    _cropSetting = [QGCropSetting new];
}

#pragma mark - Layout

- (void)setCropPixelSize:(CGSize)cropPixelSize {
    _cropPixelSize = cropPixelSize;
    [self setNeedsLayout];
}

- (void)setContentPixelSize:(CGSize)contentPixelSize {
    _contentPixelSize = contentPixelSize;
    [self setNeedsLayout];
}

#pragma mark - 布局

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect contentBounds = CGRectMake(_minimalInset.left,
                                      _minimalInset.top,
                                      CGRectGetWidth(self.bounds) - _minimalInset.left - _minimalInset.right,
                                      CGRectGetHeight(self.bounds) - _minimalInset.top - _minimalInset.bottom);
    
    if (contentBounds.size.width <= 0 || contentBounds.size.height <= 0) {
        /* 如果内容宽或高<=0, 则不处理 */
        return;
    }
    
    CGPoint center = CGPointMake(CGRectGetMidX(contentBounds), CGRectGetMidY(contentBounds));
    CGRect bounds = AVMakeRectWithAspectRatioInsideRect(_cropPixelSize, contentBounds);
    bounds.origin = CGPointZero;
    
    /* 视窗视图 */
    _viewportView.bounds = bounds;
    _viewportView.center = center;
    
    /* 旋转/缩放/平移视图 */
    _rotateView.bounds = bounds;
    _rotateView.center = center;
    
    center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    _zoomingView.bounds = bounds;
    _zoomingView.center = center;
    
    _translationView.bounds = bounds;
    _translationView.center = center;
    
    /* 计算初试缩放倍数 */
    bounds = CGRectZero;
    bounds.size = _contentPixelSize;
    
    if (_contentPixelSize.width <= 0 || _contentPixelSize.height <= 0) {
        /* 如果内容宽或高<=0, 则不处理 */
        return;
    }
    
    CGRect contentFrameInImageBounds = AVMakeRectWithAspectRatioInsideRect(_cropPixelSize, bounds);
    CGFloat scale = _viewportView.bounds.size.width / contentFrameInImageBounds.size.width;
    
    /* 容器视图 */
    CGSize scaledContentSize = CGSizeMake(_contentPixelSize.width * scale, _contentPixelSize.height * scale);
    bounds.size = scaledContentSize;
    bounds.origin = CGPointZero;
    
    _contentView.bounds = bounds;
    _contentView.center = center;
    
    /* 内容视图 */
    _content.bounds = bounds;
    _content.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    /* 遮罩视图们 */
    // 上
    CGFloat x = 0, y = 0, w = 0, h = 0;
    x = CGRectGetMinX(self.bounds);
    y = CGRectGetMinY(self.bounds);
    w = CGRectGetWidth(self.bounds);
    h = CGRectGetMinY(_viewportView.frame);
    _topMaskView.frame = CGRectMake(x, y, w, h);
    // 左
    x = CGRectGetMinX(self.bounds);
    y = CGRectGetMinY(_viewportView.frame);
    w = CGRectGetMinX(_viewportView.frame);;
    h = CGRectGetHeight(_viewportView.frame);
    _leftMaskView.frame = CGRectMake(x, y, w, h);
    // 下
    x = CGRectGetMinX(self.bounds);
    y = CGRectGetMaxY(_viewportView.frame);
    w = CGRectGetWidth(self.bounds);
    h = CGRectGetMaxY(self.bounds) - CGRectGetMaxY(_viewportView.frame);
    _bottomMaskView.frame = CGRectMake(x, y, w, h);
    // 右
    x = CGRectGetMaxX(_viewportView.frame);
    y = CGRectGetMinY(_viewportView.frame);
    w = CGRectGetMaxX(self.bounds) - CGRectGetMaxX(_viewportView.frame);
    h = CGRectGetHeight(_viewportView.frame);
    _rightMaskView.frame = CGRectMake(x, y, w, h);
    
    /* 更新裁剪参数, 更新旋转/缩放/平移视图变换 */
    CGSize newCropSize = _viewportView.bounds.size;
    CGPoint relativeTranslation = _cropSetting.relativeTranslation;
    CGPoint newTranslation = CGPointMake(relativeTranslation.x * newCropSize.width, relativeTranslation.y * newCropSize.height);
    _cropSetting.translation = newTranslation;
    _cropSetting.cropSize = newCropSize;
        
    [self updateTransformsAnimate:NO adjust:NO];
}

#pragma mark - 重置

- (void)reset {
    _cropSetting.scale = 1;
    _cropSetting.rotation = 0;
    _cropSetting.translation = CGPointZero;
}

#pragma mark - Setters / Getters

- (void)setMaskColor:(UIColor *)maskColor {
    _maskColor = maskColor;
    for (UIView *view in @[_topMaskView, _leftMaskView, _bottomMaskView, _rightMaskView]) {
        view.backgroundColor = _maskColor;
    }
}

- (void)setHideMask:(BOOL)hideMask {
    _hideMask = hideMask;
    for (UIView *view in @[_topMaskView, _leftMaskView, _bottomMaskView, _rightMaskView]) {
        view.hidden = _hideMask;
    }
}

- (void)setDisableRotation:(BOOL)disableRotation {
    _disableRotation = disableRotation;
    _rotationGesture.enabled = !_disableRotation;
}

- (void)setDisablePinch:(BOOL)disablePinch {
    _disablePinch = disablePinch;
    _pinchGesture.enabled = !_disablePinch;
}

- (void)setDisablePan:(BOOL)disablePan {
    _disablePan = disablePan;
    _panGesture.enabled = !_disablePan;
}

- (CGFloat)rotation {
    return _cropSetting.rotation;
}

- (CGFloat)scale {
    return _cropSetting.scale;
}

- (CGPoint)relativeTranslation {
    return _cropSetting.relativeTranslation;
}

#pragma mark - Public

- (void)resetContent:(UIView *)content {
    [_content removeFromSuperview];
    _content = content;
    
    [_contentView addSubview:content];
    [self setNeedsLayout];
}

#pragma mark - Update Settings

- (void)updateCropSetting:(QGCropSetting *)cropSetting animate:(BOOL)animate adjust:(BOOL)adjust {
    _cropSetting.rotation = cropSetting.rotation;
    _cropSetting.scale = cropSetting.scale;
    CGPoint relativeTranslation = cropSetting.relativeTranslation;
    CGFloat tx = relativeTranslation.x * _cropSetting.cropSize.width;
    CGFloat ty = relativeTranslation.y * _cropSetting.cropSize.height;
    _cropSetting.translation = CGPointMake(tx, ty);
    
    [self updateTransformsAnimate:animate adjust:adjust];
}

- (void)updateRotation:(CGFloat)rotation scale:(CGFloat)scale translation:(CGPoint)translation animate:(BOOL)animate adjust:(BOOL)adjust {
    CGSize size = _viewportView.bounds.size;// 视窗视图大小
    _cropSetting.rotation = rotation;
    _cropSetting.scale = scale;
    _cropSetting.translation = CGPointMake(translation.x * size.width, translation.y * size.height);
    
    [self updateTransformsAnimate:animate adjust:adjust];
}

- (void)updateRotation:(CGFloat)rotation animate:(BOOL)animate adjust:(BOOL)adjust {
    _cropSetting.rotation = rotation;
    [self updateTransformsAnimate:animate adjust:adjust];
}

- (void)updateScale:(CGFloat)scale animate:(BOOL)animate adjust:(BOOL)adjust {
    _cropSetting.scale = scale;
    [self updateTransformsAnimate:animate adjust:adjust];
}

- (void)updateTranslation:(CGPoint)translation animate:(BOOL)animate adjust:(BOOL)adjust {
    CGSize size = _viewportView.bounds.size;// 视窗视图大小
    _cropSetting.translation = CGPointMake(translation.x * size.width, translation.y * size.height);
    [self updateTransformsAnimate:animate adjust:adjust];
}

#pragma mark - 旋转/缩放/平移视图更新变换

- (void)updateTransformsAnimate:(BOOL)animate adjust:(BOOL)adjust {
    [UIView animateWithDuration:(animate ? 0.35f : 0) animations:^{
        self.rotateView.transform = CGAffineTransformMakeRotation(self.cropSetting.rotation);
        self.zoomingView.transform = CGAffineTransformMakeScale(self.cropSetting.scale, self.cropSetting.scale);
        self.translationView.transform = CGAffineTransformMakeTranslation(self.cropSetting.translation.x, self.cropSetting.translation.y);
    } completion:^(BOOL finished) {
        if (adjust) {
            [self adjustIfNeededAnimate:YES];
        }
    }];
}

#pragma mark - Actions

- (void)rotateGestureHandler:(UIRotationGestureRecognizer *)gesture {
    [self operationWillStartWithGesture:gesture];
    
    CGFloat rotation = _cropSetting.rotation + gesture.rotation;
    CGFloat adjustedRotation = [self adjustRotation:rotation previousRotation:_cropSetting.rotation];
    if (rotation == adjustedRotation) {
        gesture.rotation = 0;
    }
    
     _cropSetting.rotation = adjustedRotation;
    _rotateView.transform = CGAffineTransformMakeRotation(_cropSetting.rotation);
    [self cropSettingDidUpdateWithAnimate:NO];
    
    [self adjustWithGesture:gesture];
    [self operationDidEndWithGesture:gesture];
}

- (void)pinchGestureHandler:(UIPinchGestureRecognizer *)gesture {
    [self operationWillStartWithGesture:gesture];
    
    CGFloat scale = gesture.scale;
    gesture.scale = 1.0;
    
    _cropSetting.scale *= scale;
    _zoomingView.transform = CGAffineTransformMakeScale(_cropSetting.scale, _cropSetting.scale);
    [self cropSettingDidUpdateWithAnimate:NO];
    
    [self adjustWithGesture:gesture];
    [self operationDidEndWithGesture:gesture];
}

- (void)panGestureHandler:(UIPanGestureRecognizer *)gesture {
    [self operationWillStartWithGesture:gesture];
    
    CGPoint translation = [gesture translationInView:_zoomingView];
    [gesture setTranslation:CGPointZero inView:_zoomingView];
    
    if (gesture.state == UIGestureRecognizerStateRecognized || gesture.state == UIGestureRecognizerStateChanged) {
        _cropSetting.translation = CGPointMake(_cropSetting.translation.x + translation.x, _cropSetting.translation.y + translation.y);
        _translationView.transform = CGAffineTransformMakeTranslation(_cropSetting.translation.x, _cropSetting.translation.y);
        [self cropSettingDidUpdateWithAnimate:NO];
    }
    
    [self adjustWithGesture:gesture];
    [self operationDidEndWithGesture:gesture];
}

#pragma mark - 角度调整(吸附90度倍数角度值)

/**
 限制角度可以在一定误差范围内吸附到90度倍数的角度, 如果不在误差内则不对角度做修改.

 @param currentRotation 调整前的角度
 @param previousRotation 之前的角度
 @return 调整后的角度
 */
- (CGFloat)adjustRotation:(CGFloat)currentRotation previousRotation:(CGFloat)previousRotation {
    BOOL positive = (currentRotation >= 0);
    CGFloat rotation = fabs(currentRotation);
    CGFloat remainOfHalfPi = fmod(rotation, M_PI_2);
    
    /* 1.0度 经设计师测试后确定的角度 */
    CGFloat correction = 1.0f / 180.0f * M_PI;
    
    if (remainOfHalfPi > 0 && remainOfHalfPi <= correction) {
        rotation -= remainOfHalfPi;
    } else if (remainOfHalfPi >= (M_PI_2 - correction) && remainOfHalfPi < M_PI_2) {
        rotation += (M_PI_2 - remainOfHalfPi);
    }
    
    rotation = (positive ? 1 : -1) * rotation;
    
    return rotation;
}

#pragma mark - Operation Start/End Callback

- (void)operationWillStartWithGesture:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (_willStartCropping) {
            _willStartCropping();
        }
    }
}

- (void)operationDidEndWithGesture:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateCancelled
        || gesture.state == UIGestureRecognizerStateFailed) {
        if (_didEndCropping) {
            _didEndCropping();
        }
    }
    
    /* 旋转手势结束时, 设置角度为0 */
    if ([gesture isKindOfClass:UIRotationGestureRecognizer.class]) {
        ((UIRotationGestureRecognizer *)gesture).rotation = 0;
    }
}

#pragma mark - Adjustment

- (void)cropSettingDidUpdateWithAnimate:(BOOL)animate {
    if (_settingsChanged) {
        _settingsChanged(_cropSetting.copy, animate);
    }
}

- (void)adjustWithGesture:(UIGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded
        || gesture.state == UIGestureRecognizerStateCancelled
        || gesture.state == UIGestureRecognizerStateFailed) {
        
        [self adjustIfNeededAnimate:YES];
    }
}

- (void)adjustIfNeededAnimate:(BOOL)animate {
    /* 缩放调整 */
    CGRect bounds = _contentView.bounds;
    CGRect viewport = [_viewportView convertRect:_viewportView.bounds toView:_contentView];
    if (!CGRectContainsRect(bounds, viewport)) {
        [UIView animateWithDuration:(animate ? 0.35f : 0) animations:^{
            /* 水平方向 */
            CGFloat hScale = 1;
            if (CGRectGetWidth(viewport) > CGRectGetWidth(bounds)) {
                hScale = CGRectGetWidth(viewport) / CGRectGetWidth(bounds);
            }
            /* 竖直方向 */
            CGFloat vScale = 1;
            if (CGRectGetHeight(viewport) > CGRectGetHeight(bounds)) {
                vScale = CGRectGetHeight(viewport) / CGRectGetHeight(bounds);
            }
            self.cropSetting.scale *= MAX(hScale, vScale);
            self.zoomingView.transform = CGAffineTransformMakeScale(self.cropSetting.scale, self.cropSetting.scale);
            
            /* 平移调整 */
            CGRect bounds = self.contentView.bounds;
            CGRect viewport = [self.viewportView convertRect:self.viewportView.bounds toView:self.contentView];
            if (!CGRectContainsRect(bounds, viewport)) {
                CGPoint translation = self.cropSetting.translation;
                /* 水平方向 */
                if (CGRectGetMaxX(viewport) > CGRectGetMaxX(bounds)) {
                    translation.x += CGRectGetMaxX(viewport) - CGRectGetMaxX(bounds);
                } else if (CGRectGetMinX(viewport) < CGRectGetMinX(bounds)) {
                    translation.x += CGRectGetMinX(viewport) - CGRectGetMinX(bounds);
                }
                /* 竖直方向 */
                if (CGRectGetMaxY(viewport) > CGRectGetMaxY(bounds)) {
                    translation.y += CGRectGetMaxY(viewport) - CGRectGetMaxY(bounds);
                } else if (CGRectGetMinY(viewport) < CGRectGetMinY(bounds)) {
                    translation.y += CGRectGetMinY(viewport) - CGRectGetMinY(bounds);
                }
                
                self.cropSetting.translation = translation;
                self.translationView.transform = CGAffineTransformMakeTranslation(translation.x, translation.y);
            }
        }];
        
        [self cropSettingDidUpdateWithAnimate:YES];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureA shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)gestureB {
    BOOL gestureAIsPinch = [gestureA isKindOfClass:UIPinchGestureRecognizer.class];
    BOOL gestureAIsRotation = [gestureA isKindOfClass:UIRotationGestureRecognizer.class];
    BOOL gestureBIsPinch = [gestureB isKindOfClass:UIPinchGestureRecognizer.class];
    BOOL gestureBIsRotation = [gestureB isKindOfClass:UIRotationGestureRecognizer.class];
    if ((gestureAIsPinch && gestureBIsRotation) || (gestureAIsRotation && gestureBIsPinch)) {
        return YES;
    } else {
        return NO;
    }
}

@end
