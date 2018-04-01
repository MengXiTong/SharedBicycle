//
//  ViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/2/23.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "CycleViewController.h"
#import "MenuViewController.h"
#import <AFNetworking.h>
#import <UIViewController+CWLateralSlide.h>
#import "ScanCodeViewController.h"
#import "UserInfoViewController.h"

@interface CycleViewController ()

@end

@implementation CycleViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVite];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initVite {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leftViewShow:(id)sender {
    MenuViewController *vc = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    UINavigationController *navC = self.navigationController;
    [navC cw_showDefaultDrawerViewController:vc];
}
- (IBAction)scanning:(id)sender {
    ScanCodeViewController *scanCodeVC = [[ScanCodeViewController alloc] init];
    [[self navigationController] pushViewController:scanCodeVC animated:YES];
}

@end
