//
//  CouponTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/23.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "CouponTableViewController.h"
#import "CouponTableViewCell.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"
#import "CycleViewController.h"

@interface CouponTableViewController ()

@end

@implementation CouponTableViewController{
    NSMutableArray *listCoupon;
    AFHTTPSessionManager *manager;
    NSString *strURL;
    MBProgressHUD *HUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView{
    if([_type isEqualToString:@"select"]){
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"不使用" style:UIBarButtonItemStyleDone target:self action:@selector(actionUnUse:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
}

- (void)initValue{
    [self initHUD];
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: CouponHandler];
    NSDictionary *param = @{@"UserID":_user.UserID};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            listCoupon = [responseObject objectForKey:@"couponList"];
            [self.tableView reloadData];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"CouponError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listCoupon.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicCoupon = listCoupon[indexPath.row];
    CouponTableViewCell *couponCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierCoupon" forIndexPath:indexPath];
    couponCell.lblExpirationDate.text = [NSString stringWithFormat:@"有效期至：%@",[dicCoupon objectForKey:@"ExpirationDate"]];
    couponCell.lblFavorablePrice.text = [NSString stringWithFormat:@"%i",[[dicCoupon objectForKey:@"FavorablePrice"] intValue]];
    if([_type isEqualToString:@"select"]){
        couponCell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    else if([_type isEqualToString:@"unselect"]){
        couponCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return couponCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicCoupon = listCoupon[indexPath.row];
    CouponTableViewCell *couponCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierCoupon" forIndexPath:indexPath];
    if(couponCell.selectionStyle == UITableViewCellSelectionStyleDefault){
        CycleViewController *cycleVC = (CycleViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        float favorablePrice = [[dicCoupon objectForKey:@"FavorablePrice"] floatValue];
        cycleVC.lblPayCoupon.text = [NSString stringWithFormat:@"优惠券：-%0.2f元>",favorablePrice];
        float realPrice = [cycleVC.trip.Consume floatValue]-favorablePrice;
        if(realPrice<0){
            realPrice = 0;
        }
        cycleVC.lblPayReal.text = [NSString stringWithFormat:@"%0.2f",realPrice];
        cycleVC.trip.CouponID = [dicCoupon objectForKey:@"CouponID"];
        [self.navigationController popToViewController:cycleVC animated:true];
    }
}

- (IBAction)actionUnUse:(id)sender{
    CycleViewController *cycleVC = (CycleViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    cycleVC.trip.CouponID = nil;
    cycleVC.lblPayReal.text = [NSString stringWithFormat:@"%0.2f",[cycleVC.trip.Consume floatValue]];
    cycleVC.lblPayCoupon.text = @"优惠券>";
    [self.navigationController popToViewController:cycleVC animated:true];
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"加载中";
    [HUD showAnimated:YES];
}

@end
