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
#import "CouponTableViewController.h"

@interface RedViewController ()
@end

@implementation RedViewController{
    AFHTTPSessionManager *manager;
    NSString *strURL;
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
    strURL = [HTTP stringByAppendingString: CouponHandler];
    if([_type isEqualToString:@"show"]){
        [self showRed];
    }
    else if([_type isEqualToString:@"over"]){
        [self overRed];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionOpenRed:(id)sender {
    [self openRed];
}
- (IBAction)actionLook:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CouponTableViewController *couponTblVC = (CouponTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDCouponTblVC"];
    couponTblVC.user = _user;
    couponTblVC.type = @"unselect";
    [self.navigationController pushViewController:couponTblVC animated:YES];
}

- (void)showRed{
    _imgBg.image = [UIImage imageNamed:@"Red"];
    [_btnLook setHidden:YES];
    [_btnOpen setHidden:NO];
    [_lblHide setHidden:YES];
    [_lblCouponTypeName setHidden:YES];
}

- (void)openRed{
    [self initHUD];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *param = @{@"UserID":_user.UserID};
    [manager POST:strURL parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSDictionary *dicCoupon = [responseObject objectForKey:@"coupon"];
            _lblCouponTypeName.text = [dicCoupon objectForKey:@"CouponTypeName"];
            _imgBg.image = [UIImage imageNamed:@"RedOpen"];
            [_btnLook setHidden:NO];
            [_btnOpen setHidden:YES];
            [_lblHide setHidden:YES];
            [_lblCouponTypeName setHidden:NO];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"RedError: %@",error);
        [HUD removeFromSuperview];
    }];
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
    HUD.label.text = @"请稍等";
    [HUD showAnimated:YES];
}

@end
