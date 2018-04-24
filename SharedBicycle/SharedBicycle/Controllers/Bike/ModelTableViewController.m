//
//  ModelTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "ModelTableViewController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"
#import "BikeSearchTableViewController.h"
#import "CommonTableViewCell.h"
#import "BikeDetailTableViewController.h"

@interface ModelTableViewController ()

@end

@implementation ModelTableViewController{
    AFHTTPSessionManager *manager;
    NSString *strURL;
    MBProgressHUD *HUD;
    NSMutableArray *listModel;
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
    self.navigationItem.title = @"单车型号";
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifierModel"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: BikeHandler];
    [self initValue];
}

-(void)initValue{
    [self initHUD];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *param = @{@"Type":@"model"};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            listModel = [responseObject objectForKey:@"modelList"];
            [self.tableView reloadData];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"ModelError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listModel.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicModel = listModel[indexPath.row];
    CommonTableViewCell *modelCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierModel" forIndexPath:indexPath];
    modelCell.lblShow.text = [dicModel objectForKey:@"ModelName"];
    return modelCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicModel = listModel[indexPath.row];
    if([_comeFrom isEqualToString:@"bikeSearch"]){
        BikeSearchTableViewController *bikeSearchTblVC = (BikeSearchTableViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        _bike.ModelID = [dicModel objectForKey:@"ModelID"];
        _bike.ModelName = [dicModel objectForKey:@"ModelName"];
        bikeSearchTblVC.lblModel.text = _bike.ModelName;
        [self.navigationController popToViewController:bikeSearchTblVC animated:true];
        return;
    }
    if([_comeFrom isEqualToString:@"bikeDetail"]){
        BikeDetailTableViewController *bikeDetailTblVC = (BikeDetailTableViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
        _bike.ModelID = [dicModel objectForKey:@"ModelID"];
        _bike.ModelName = [dicModel objectForKey:@"ModelName"];
        bikeDetailTblVC.lblModel.text = _bike.ModelName;
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
