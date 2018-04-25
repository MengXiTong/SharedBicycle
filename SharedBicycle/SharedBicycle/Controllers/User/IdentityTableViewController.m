//
//  IdentityTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/25.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "IdentityTableViewController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"
#import "IdentityValidateTableViewController.h"
#import "CommonTableViewCell.h"

@interface IdentityTableViewController ()

@end

@implementation IdentityTableViewController{
    AFHTTPSessionManager *manager;
    NSString *strURL;
    MBProgressHUD *HUD;
    NSMutableArray *listIdentity;
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
    self.navigationItem.title = @"身份信息";
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifierIdentity"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: UserHandler];
    [self initValue];
}

-(void)initValue{
    [self initHUD];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *param = @{@"Type":@"identity"};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            listIdentity = [responseObject objectForKey:@"identityList"];
            [self.tableView reloadData];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"IdentityError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listIdentity.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicIdentity = listIdentity[indexPath.row];
    CommonTableViewCell *stateCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierIdentity" forIndexPath:indexPath];
    stateCell.lblShow.text = [dicIdentity objectForKey:@"IdentityName"];
    return stateCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicIdentity = listIdentity[indexPath.row];
    IdentityValidateTableViewController *identityValidateTblVC = (IdentityValidateTableViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    _user.IdentityID = [dicIdentity objectForKey:@"IdentityID"];
    identityValidateTblVC.lblIdentity.text = [dicIdentity objectForKey:@"IdentityName"];
    [self.navigationController popToViewController:identityValidateTblVC animated:true];
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"加载中";
    [HUD showAnimated:YES];
}

@end
