//
//  QGBaseViewController.m
//  QGCropView
//
//  Created by 宇园 on 2018/8/16.
//

#import "QGBaseViewController.h"
#import "QGMacro.h"

@interface QGBaseViewController ()

@end

@implementation QGBaseViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (nibBundleOrNil == nil) {
        nibBundleOrNil = [NSBundle bundleForClass:self.class];
    }
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    // 顶部空白适配
    if (self.viewTop) {
        self.viewTop.constant = [self extraTopSpace];
    }
    // 底部空白适配
    if (self.viewBottom) {
        self.viewBottom.constant = QG_ViewControllerBottomSpace;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
