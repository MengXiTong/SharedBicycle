//
//  RechargeViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/26.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "RechargeViewController.h"
#import <MBProgressHUD.h>
#import "Config.h"
#import <AFNetworking.h>
#import "WalletTableViewController.h"
#import "Toast.h"
#import "Until.h"

@interface RechargeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblExplain;
@property (weak, nonatomic) IBOutlet UITextField *tfBalance;
@property (weak, nonatomic) IBOutlet UIButton *btnAction;

@end

@implementation RechargeViewController{
    MBProgressHUD *HUD;
    AFHTTPSessionManager *manager;
    NSString *strURL;
    WalletTableViewController *wallerTblVC;
    CGRect screen;
    CGRect cGRect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView {
    //获取屏幕信息
    screen = [[UIScreen mainScreen] bounds];
    cGRect = CGRectMake((screen.size.width-270)/2, (screen.size.height-40)/2, 270, 40);
    wallerTblVC = (WalletTableViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    [Until setKeyboardHide:self.view];
    //初始化Session
    manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    strURL = [HTTP stringByAppendingString: UserHandler];
    if([_comeFrom isEqualToString:@"balance"]){
        self.navigationItem.title = @"充值";
        _lblExplain.text = @"充值金额";
        [_btnAction setTitle:@"立即充值" forState:UIControlStateNormal];
    }
    else if([_comeFrom isEqualToString:@"deposit"]){
        self.navigationItem.title = @"交押金";
        _lblExplain.text = @"押金金额";
        _tfBalance.text = @"90.0";
        [_tfBalance setEnabled:NO];
        [_btnAction setTitle:@"确认支付" forState:UIControlStateNormal];
    }
}

- (void)putBalance{
    [self initHUD];
    NSDictionary *user = @{@"UserID":_user.UserID,@"Balance":_tfBalance.text};
    NSDictionary *param = @{@"type":@"balance",@"user":user};
    [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            [Toast showAlertWithMessage:@"充值成功" withView:self];
            float banlance = [_user.Balance floatValue]+[_tfBalance.text floatValue];
            _user.Balance = [NSString stringWithFormat:@"%f",banlance];
            wallerTblVC.lblBalance.text = [NSString stringWithFormat:@"%0.2f元",[_user.Balance floatValue]];
            [self.navigationController popToViewController:wallerTblVC animated:YES];
        }
        else{
            [Toast showAlertWithMessage:@"充值失败" withView:self];
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [HUD removeFromSuperview];
        NSLog(@"RechargeError: %@",error);
    }];
}

- (void)putDeposit{
    [self initHUD];
    NSDictionary *user = @{@"UserID":_user.UserID,@"Deposit":_tfBalance.text};
    NSDictionary *param = @{@"type":@"deposit",@"user":user};
    [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            [Toast showAlertWithMessage:@"交押金成功" withView:self];
            _user.Deposit = [NSString stringWithFormat:@"%f",[_tfBalance.text floatValue]];
            wallerTblVC.lblDeposit.text = @"已交";
            [self.navigationController popToViewController:wallerTblVC animated:YES];
        }
        else{
            [Toast showAlertWithMessage:@"交押金失败" withView:self];
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [HUD removeFromSuperview];
        NSLog(@"RechargeError: %@",error);
    }];
}

- (IBAction)actionRecharge:(id)sender {
    [Until keyboardHide:nil];
    if([_comeFrom isEqualToString:@"balance"]){
        if([Until checkMoney:_tfBalance.text]){
            [self putBalance];
        }
        else{
            [Toast showAlertWithMessage:@"请输入1000以内，最多两位小数" withView:self withCGRect:&(cGRect)];
        }
    }
    else if([_comeFrom isEqualToString:@"deposit"]){
        [self putDeposit];
    }
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"请稍等";
    [HUD showAnimated:YES];
}

@end
