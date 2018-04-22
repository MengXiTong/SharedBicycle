//
//  RedViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/22.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "RedViewController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"

@interface RedViewController ()
@end

@implementation RedViewController{
    AFHTTPSessionManager *manager;
    MBProgressHUD *HUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)initView{
    //初始化session
    manager = [AFHTTPSessionManager manager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionOpenRed:(id)sender {
    [self openRed];
}
- (IBAction)actionLook:(id)sender {
}

- (void)showRed{
    _imgBg.image = [UIImage imageNamed:@"Red"];
    [_btnLook setHidden:YES];
    [_btnOpen setHidden:NO];
    [_lblHide setHidden:YES];
    [_lblCouponTypeName setHidden:YES];
    [self initHUD];
    NSString *strURL = [HTTP stringByAppendingString: TripHandler];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
}

- (void)openRed{
    _imgBg.image = [UIImage imageNamed:@"RedOpen"];
    [_btnLook setHidden:NO];
    [_btnOpen setHidden:YES];
    [_lblHide setHidden:YES];
    [_lblCouponTypeName setHidden:NO];
    [self initHUD];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
}

- (void)overRed{
    _imgBg.image = [UIImage imageNamed:@"RedOver"];
    [_btnLook setHidden:YES];
    [_btnOpen setHidden:YES];
    [_lblHide setHidden:NO];
    [_lblCouponTypeName setHidden:YES];
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"加载中";
    [HUD showAnimated:YES];
}

@end
