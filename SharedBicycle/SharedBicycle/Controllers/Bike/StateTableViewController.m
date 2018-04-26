//
//  StateTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "StateTableViewController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"
#import "BikeSearchTableViewController.h"
#import "CommonTableViewCell.h"
#import "BikeDetailTableViewController.h"

@interface StateTableViewController ()

@end

@implementation StateTableViewController{
    AFHTTPSessionManager *manager;
    NSString *strURL;
    MBProgressHUD *HUD;
    NSMutableArray *listState;
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
    self.navigationItem.title = @"单车状态";
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifierState"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: BikeHandler];
    [self initValue];
}

-(void)initValue{
    [self initHUD];
    NSDictionary *param = @{@"Type":@"state"};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            listState = [responseObject objectForKey:@"stateList"];
            [self.tableView reloadData];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"StateError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listState.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicState = listState[indexPath.row];
    CommonTableViewCell *stateCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierState" forIndexPath:indexPath];
    stateCell.lblShow.text = [dicState objectForKey:@"StateName"];
    return stateCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicState = listState[indexPath.row];
    if([_comeFrom isEqualToString:@"bikeSearch"]){
        BikeSearchTableViewController *bikeSearchTblVC = (BikeSearchTableViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        _bike.StateID = [dicState objectForKey:@"StateID"];
        _bike.StateName = [dicState objectForKey:@"StateName"];
        bikeSearchTblVC.lblState.text = _bike.StateName;
        [self.navigationController popToViewController:bikeSearchTblVC animated:true];
        return;
    }
    if([_comeFrom isEqualToString:@"bikeDetail"]){
        BikeDetailTableViewController *bikeDetailTblVC = (BikeDetailTableViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        _bike.StateID = [dicState objectForKey:@"StateID"];
        _bike.StateName = [dicState objectForKey:@"StateName"];
        bikeDetailTblVC.lblState.text = _bike.StateName;
        [self.navigationController popToViewController:bikeDetailTblVC animated:true];
        return;
    }
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"加载中";
    [HUD showAnimated:YES];
}

@end
