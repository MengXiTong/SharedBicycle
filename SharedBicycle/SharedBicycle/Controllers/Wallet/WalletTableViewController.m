//
//  WalletTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "WalletTableViewController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"
#import "DetailedTableViewController.h"
#import "CouponTableViewController.h"
#import "RechargeViewController.h"
#import "Toast.h"

@interface WalletTableViewController ()

@end

@implementation WalletTableViewController{
    AFHTTPSessionManager *manager;
    MBProgressHUD *HUD;
    UIStoryboard *storyboard;
    RechargeViewController *rechargeTblVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView{
    self.navigationItem.title = @"我的钱包";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _lblBalance.text = [NSString stringWithFormat:@"%0.2f元",[_user.Balance floatValue]];
    _lblDeposit.text = [_user.Deposit floatValue]>0?@"已交":@"未交";
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    manager = [AFHTTPSessionManager manager];
    [self initValue];
}

- (void)initValue{
    [self initHUD];
    NSString *strURL = [HTTP stringByAppendingString: CouponHandler];
    manager = [AFHTTPSessionManager manager];
    NSDictionary *param = @{@"UserID":_user.UserID,@"Type":@"count"};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            _lblCoupon.text = [NSString stringWithFormat:@"%@张",[responseObject objectForKey:@"couponCount"]];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"WalletError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (void)putBackDeposit{
    [self initHUD];
    NSString *strURL = [HTTP stringByAppendingString: UserHandler];
    NSDictionary *user = @{@"UserID":_user.UserID};
    NSDictionary *param = @{@"type":@"backDeposit",@"user":user};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            [Toast showAlertWithMessage:@"退押金成功" withView:self];
            _user.Deposit = @"0.00";
            _lblDeposit.text = @"未交";
            [self.cellDeposit setSelected:NO animated:YES];
        }
        else{
            [Toast showAlertWithMessage:@"退押金失败" withView:self];
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [HUD removeFromSuperview];
        NSLog(@"WalletError: %@",error);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 1:{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CouponTableViewController *couponTblVC = (CouponTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDCouponTblVC"];
            couponTblVC.user = _user;
            couponTblVC.type = @"unselect";
            [self.navigationController pushViewController:couponTblVC animated:YES];
            break;
        }
        case 2:{
            if([_user.Deposit floatValue]>0){
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"退押金将无法使用共享单车，确定要退吗？" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"退押金" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self putBackDeposit];
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"留下来" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self.cellDeposit setSelected:NO animated:YES];
                }];
                [alert addAction:cancelAction];
                [alert addAction:confirmAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else{
                rechargeTblVC = (RechargeViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDRechargeVC"];
                rechargeTblVC.comeFrom = @"deposit";
                rechargeTblVC.user = _user;
                [self.navigationController pushViewController:rechargeTblVC animated:YES];
            }
            break;
        }
        case 3:{
            DetailedTableViewController *detailedTblVC = [[DetailedTableViewController alloc] init];
            detailedTblVC.user = _user;
            [self.navigationController pushViewController:detailedTblVC animated:YES];
            break;
        }
        default:
            break;
    }
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"加载中";
    [HUD showAnimated:YES];
}
- (IBAction)actionBalance:(id)sender {
    rechargeTblVC = (RechargeViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDRechargeVC"];
    rechargeTblVC.comeFrom = @"balance";
    rechargeTblVC.user = _user;
    [self.navigationController pushViewController:rechargeTblVC animated:YES];
}

@end
