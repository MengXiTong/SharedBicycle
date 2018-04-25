//
//  CreditScoreTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/25.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "CreditScoreTableViewController.h"
#import "InfoShowTableViewCell.h"
#import <AFNetworking.h>
#import "Config.h"
#import <MJRefresh.h>

@interface CreditScoreTableViewController ()

@end

@implementation CreditScoreTableViewController{
    NSMutableArray *listCreditScore;
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
    self.navigationItem.title = @"我的信用分";
    isLast = false;
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: UserHandler];
    [self.tableView registerNib:[UINib nibWithNibName:@"InfoShowTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifierCreditScore"];
    [self.tableView setRowHeight:70];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self loadNewData];
}

- (void)loadNewData{
    pageNum = 1;
    listCreditScore = [[NSMutableArray alloc] init];
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
    NSDictionary *param = @{@"UserID":_user.UserID,@"Type":@"creditScore",@"PageNum":[NSString stringWithFormat:@"%i",pageNum]};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSMutableArray *list = [responseObject objectForKey:@"creditScoreList"];
            if(list.count<10){
                isLast = true;
            }
            else{
                isLast = false;
            }
            if(list.count>0){
                [listCreditScore addObjectsFromArray:list];
            }
            [self.tableView reloadData];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        callBack();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"CreditScoreError: %@",error);
        callBack();
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listCreditScore.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicCreditScore = listCreditScore[indexPath.row];
    InfoShowTableViewCell *creditScoreCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierCreditScore" forIndexPath:indexPath];
    creditScoreCell.lblExplain.text = [dicCreditScore objectForKey:@"Explain"];
    creditScoreCell.lblTime.text = [dicCreditScore objectForKey:@"Time"];
    int score = [[dicCreditScore objectForKey:@"Score"] intValue];
    if (score>0) {
        creditScoreCell.lblValue.text = [NSString stringWithFormat:@"+%i信用分",score];
    }
    else{
        creditScoreCell.lblValue.text = [NSString stringWithFormat:@"%i信用分",score];
    }
    [creditScoreCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return creditScoreCell;
}

@end
