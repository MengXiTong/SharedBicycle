//
//  RepairTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/26.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "RepairTableViewController.h"
#import <AFNetworking.h>
#import "Config.h"
#import <MJRefresh.h>
#import "RepairTableViewCell.h"
#import "Toast.h"

@interface RepairTableViewController ()

@end

@implementation RepairTableViewController{
    NSMutableArray *listRepair;
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
    self.navigationItem.title = @"订单记录";
    isLast = false;
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: RepairHandler];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    [self loadNewData];
}

- (void)loadNewData{
    pageNum = 1;
    listRepair = [[NSMutableArray alloc] init];
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
    NSDictionary *param = @{@"UserID":_user.UserID,@"PageNum":[NSString stringWithFormat:@"%i",pageNum]};
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSMutableArray *list = [responseObject objectForKey:@"repairList"];
            if(list.count<10){
                isLast = true;
            }
            else{
                isLast = false;
            }
            if(list.count>0){
                [listRepair addObjectsFromArray:list];
            }
            [self.tableView reloadData];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        callBack();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"RepairTblError: %@",error);
        callBack();
    }];
}

- (void)putRepair:(void(^)(void))callBack withRepairID:(NSString *)strRepairID withBikeID:(NSString *)strBikeID{
    NSDictionary *repair = @{@"RepairID":strRepairID,@"BikeID":strBikeID};
    NSDictionary *param = @{@"type":@"over",@"repair":repair};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            [Toast showAlertWithMessage:@"维护完成成功" withView:self];
            callBack();
        }
        else{
            [Toast showAlertWithMessage:@"维护完成失败" withView:self];
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"RepairTblError: %@",error);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listRepair.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicRepair = listRepair[indexPath.row];
    RepairTableViewCell *repairTblVC = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierRepair" forIndexPath:indexPath];
    repairTblVC.lblBikeID.text = [NSString stringWithFormat:@"车牌号：%@",[dicRepair objectForKey:@"BikeID"]];
    repairTblVC.lblUser.text = [NSString stringWithFormat:@"报修人：%@",[dicRepair objectForKey:@"UserID"]];
    NSString *strState = [dicRepair objectForKey:@"RepairState"];
    if([strState isEqualToString:@"finish"]){
        [repairTblVC setSelectionStyle:UITableViewCellSelectionStyleNone];
        strState = @"维修完成";
        repairTblVC.lblState.textColor = [UIColor greenColor];
    }
    else{
        [repairTblVC setSelectionStyle:UITableViewCellSelectionStyleDefault];
        repairTblVC.lblState.textColor = [UIColor redColor];
        if([strState isEqualToString:@"achieve"]){
            strState = @"已回收";
        }
        else if([strState isEqualToString:@"unfinish"]){
            strState = @"未回收";
        }
    }
    repairTblVC.lblState.text = [NSString stringWithFormat:@"状态：%@",strState];
    repairTblVC.lblRepairUserID.text = [NSString stringWithFormat:@"维修人：%@",[dicRepair objectForKey:@"RepairUserID"]];
    repairTblVC.lblContent.text = [NSString stringWithFormat:@"故障说明：%@",[dicRepair objectForKey:@"RepairContent"]];
    repairTblVC.lblTime.text = [NSString stringWithFormat:@"报修时间：%@",[dicRepair objectForKey:@"RepairTime"]];
    return repairTblVC;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicRepair = listRepair[indexPath.row];
    RepairTableViewCell *repairTblVC = [tableView cellForRowAtIndexPath:indexPath];
    if(repairTblVC.selectionStyle == UITableViewCellSelectionStyleDefault){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否完成维修工作？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self putRepair:^{
                [repairTblVC setSelected:NO animated:YES];
                [repairTblVC setSelectionStyle:UITableViewCellSelectionStyleNone];
                repairTblVC.lblState.text = @"状态：维修完成";
                repairTblVC.lblState.textColor = [UIColor greenColor];
            } withRepairID:[dicRepair objectForKey:@"RepairID"]withBikeID:[dicRepair objectForKey:@"BikeID"]];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [repairTblVC setSelected:NO animated:YES];
        }];
        [alert addAction:cancelAction];
        [alert addAction:confirmAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
