//
//  QGBaseViewController.h
//  Masonry
//
//  Created by 宇园 on 2018/8/16.
//

#import <UIKit/UIKit.h>

@interface QGBaseViewController : UIViewController

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *viewTop;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *viewBottom;

/**
 使用自定已导航栏, 需要添加的顶部空白距离
 */
@property (nonatomic, assign, readonly) CGFloat extraTopSpace;

@end
