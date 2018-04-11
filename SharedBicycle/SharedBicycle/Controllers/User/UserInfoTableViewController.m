//
//  UserInfoTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/11.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "UserInfoTableViewController.h"

@interface UserInfoTableViewController ()

@end

@implementation UserInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    //去除多余的表格分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //初始化导航栏
    self.navigationItem.title = @"个人信息";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
