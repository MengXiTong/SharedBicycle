//
//  TripTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/23.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "TripTableViewController.h"
#import "TripTableViewCell.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"

@interface TripTableViewController ()

@end

@implementation TripTableViewController{
    NSMutableArray *listTrip;
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
    self.navigationItem.title = @"我的行程";
}

- (void)initValue{
    [self initHUD];
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: TripHandler];
    NSDictionary *param = @{@"UserID":_user.UserID,@"Type":@"info"};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            listTrip = [responseObject objectForKey:@"tripList"];
            [self.tableView reloadData];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"TripError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listTrip.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicTrip = listTrip[indexPath.row];
    TripTableViewCell *tripCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierTrip" forIndexPath:indexPath];
    tripCell.lblStartTime.text = [dicTrip objectForKey:@"StartTime"];
    tripCell.lblInfo.text = [NSString stringWithFormat:@"车牌号%@ | 花费%0.2f元",[dicTrip objectForKey:@"BikeID"],[[dicTrip objectForKey:@"Consume"] floatValue]];
    return tripCell;
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"加载中";
    [HUD showAnimated:YES];
}

@end
