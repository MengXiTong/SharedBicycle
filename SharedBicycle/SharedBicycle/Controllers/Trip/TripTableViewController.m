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
#import <MJRefresh.h>
#import "TripDetailViewController.h"

@interface TripTableViewController ()

@end

@implementation TripTableViewController{
    NSMutableArray *listTrip;
    AFHTTPSessionManager *manager;
    NSString *strURL;
    int pageNum;
    bool isLast;
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
    self.navigationItem.title = @"我的行程";
    isLast = false;
    [self loadNewData];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)loadNewData{
    pageNum = 1;
    listTrip = [[NSMutableArray alloc] init];
    [self initValue:^{
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer setState:MJRefreshStateIdle];
    }];
}

- (void)loadMoreData{
    if(isLast){
        [self.tableView.mj_footer setState:MJRefreshStateNoMoreData];
    }
    else{
        pageNum++;
        [self initValue:^{
            [self.tableView.mj_footer endRefreshing];
        }];
    }
}

- (void)initValue:(void(^)(void))callBack{
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: TripHandler];
    NSDictionary *param = @{@"UserID":_user.UserID,@"Type":@"info",@"PageNum":[NSString stringWithFormat:@"%i",pageNum]};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSMutableArray *list = [responseObject objectForKey:@"tripList"];
            if(list.count>0){
                isLast = false;
                [listTrip addObjectsFromArray:list];
                [self.tableView reloadData];
            }
            else{
                isLast = true;
            }
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        callBack();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"TripError: %@",error);
        callBack();
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TripDetailViewController *tripDetailVC = (TripDetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDTripDetailVC"];
    tripDetailVC.user = _user;
    tripDetailVC.trip = [[Trip alloc] init];
    tripDetailVC.trip.TripID = [listTrip[indexPath.row] objectForKey:@"TripID"];
    [self.navigationController pushViewController:tripDetailVC animated:YES];
}

@end
