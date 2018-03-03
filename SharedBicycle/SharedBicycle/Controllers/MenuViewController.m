//
//  LeftViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/3/3.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "MenuViewController.h"
#import "UIViewController+CWLateralSlide.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    CGRect rect = self.view.frame;

    switch (_drawerType) {
        case DrawerDefaultLeft:
            [self.view.superview sendSubviewToBack:self.view];
            break;
        case DrawerTypeMaskLeft:
            rect.size.width = CGRectGetWidth(self.view.frame) * 0.75;
            break;
        default:
            break;
    }

    self.view.frame = rect;
}

@end
