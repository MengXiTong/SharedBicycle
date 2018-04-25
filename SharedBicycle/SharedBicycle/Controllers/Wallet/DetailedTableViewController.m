//
//  DetailedTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/25.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "DetailedTableViewController.h"
#import "InfoShowTableViewCell.h"
#import <AFNetworking.h>
#import "Config.h"
#import <MJRefresh.h>

@interface DetailedTableViewController ()

@end

@implementation DetailedTableViewController{
    NSMutableArray *listDetailed;
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
    self.navigationItem.title = @"消费明细";
    isLast = false;
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: UserHandler];
    [self.tableView registerNib:[UINib nibWithNibName:@"InfoShowTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifierDetailed"];
    [self.tableView setRowHeight:70];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self loadNewData];
}

- (void)loadNewData{
    pageNum = 1;
    listDetailed = [[NSMutableArray alloc] init];
    [self initValue:^{
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer resetNoMoreData];
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
    NSDictionary *param = @{@"UserID":_user.UserID,@"Type":@"detailed",@"PageNum":[NSString stringWithFormat:@"%i",pageNum]};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSMutableArray *list = [responseObject objectForKey:@"detailedList"];
            if(list.count<10){
                isLast = true;
            }
            else{
                isLast = false;
            }
            if(list.count>0){
                [listDetailed addObjectsFromArray:list];
            }
            [self.tableView reloadData];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        callBack();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"DetailedError: %@",error);
        callBack();
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listDetailed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicDetailed = listDetailed[indexPath.row];
    InfoShowTableViewCell *detailedCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierDetailed" forIndexPath:indexPath];
    detailedCell.lblExplain.text = [dicDetailed objectForKey:@"DetailedTypeName"];
    detailedCell.lblTime.text = [dicDetailed objectForKey:@"DetailTime"];
    detailedCell.lblValue.text = [NSString stringWithFormat:@"%0.2f元",[[dicDetailed objectForKey:@"Sum"] floatValue]];
    [detailedCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return detailedCell;
}

@end
