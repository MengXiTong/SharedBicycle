//
//  BikeTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "BikeTableViewController.h"
#import "BikeTableViewCell.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"
#import <MJRefresh.h>
#import "BikeDetailTableViewController.h"
#import "BikeSearchTableViewController.h"

@interface BikeTableViewController ()

@end

@implementation BikeTableViewController{
    NSMutableArray *listBike;
    AFHTTPSessionManager *manager;
    NSString *strURL;
    int pageNum;
    bool isLast;
    UIStoryboard *storyboard;
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
    isLast = false;
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: BikeHandler];
    _bike = [[Bike alloc] init];
    _bike.BikeID = @"";
    _bike.ModelID = @"";
    _bike.StateID = @"";
    _bike.ModelName = @"";
    _bike.StateName = @"";
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([_comeFrom isEqualToString:@"info"]) {
        self.navigationItem.title = @"单车信息";
        UIBarButtonItem *rightBarButtonItemAdd = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"AddBike"] style:UIBarButtonItemStyleDone target:self action:@selector(actionAdd:)];
        UIBarButtonItem *rightBarButtonItemSearch = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SearchBike"] style:UIBarButtonItemStyleDone target:self action:@selector(actionSearch:)];
        self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:rightBarButtonItemSearch,rightBarButtonItemAdd,nil];
    }
    else if([_comeFrom isEqualToString:@"repair"]){
        self.navigationItem.title = @"维修处理";
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"我的订单" style:UIBarButtonItemStyleDone target:self action:@selector(actionMyOrder:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        _bike.StateID = @"3";
    }
    [self loadNewData];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)loadNewData{
    pageNum = 1;
    listBike = [[NSMutableArray alloc] init];
    [self getValue:^{
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
        [self getValue:^{
            [self.tableView.mj_footer endRefreshing];
        }];
    }
}

- (void)getValue:(void(^)(void))callBack{
    NSDictionary *param = @{@"Type":@"bike",@"SubType":@"info",@"PageNum":[NSString stringWithFormat:@"%i",pageNum],@"BikeID":_bike.BikeID,@"ModelID":_bike.ModelID,@"StateID":_bike.StateID};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSMutableArray *list = [responseObject objectForKey:@"bikeList"];
            if(list.count<10){
                isLast = true;
            }
            else{
                isLast = false;
            }
            if(list.count>0){
                [listBike addObjectsFromArray:list];
            }
            [self.tableView reloadData];
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
    return listBike.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicBike = listBike[indexPath.row];
    BikeTableViewCell *bikeCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierBike" forIndexPath:indexPath];
    bikeCell.lblBikeID.text = [NSString stringWithFormat:@"车牌号：%@",[dicBike objectForKey:@"BikeID"]];
    bikeCell.lblModel.text = [NSString stringWithFormat:@"车型：%@",[dicBike objectForKey:@"ModelName"]];
    bikeCell.lblState.text = [NSString stringWithFormat:@"状态：%@",[dicBike objectForKey:@"StateName"]];
    bikeCell.lblPosition.text = [NSString stringWithFormat:@"经纬度：%@,%@",[dicBike objectForKey:@"BikeLongitude"],[dicBike objectForKey:@"BikeLatitude"]];
    return bikeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_comeFrom isEqualToString:@"info"]) {
        NSDictionary *dicBike = listBike[indexPath.row];
        BikeDetailTableViewController *bikeDetailTblVC = (BikeDetailTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDBikeDetailTblVC"];
        bikeDetailTblVC.comeFrom = @"updateBike";
        Bike *updateBike = [[Bike alloc] init];
        updateBike.BikeID = [dicBike objectForKey:@"BikeID"];
        updateBike.ModelID = [dicBike objectForKey:@"ModelID"];
        updateBike.StateID = [dicBike objectForKey:@"StateID"];
        updateBike.BikeLongitude = [dicBike objectForKey:@"BikeLongitude"];
        updateBike.BikeLatitude = [dicBike objectForKey:@"BikeLatitude"];
        updateBike.ModelName = [dicBike objectForKey:@"ModelName"];
        updateBike.StateName = [dicBike objectForKey:@"StateName"];
        bikeDetailTblVC.bike = updateBike;
        [self.navigationController pushViewController:bikeDetailTblVC animated:YES];
    }
    else if([_comeFrom isEqualToString:@"repair"]){
        
    }
}

- (IBAction)actionAdd:(id)sender{
    BikeDetailTableViewController *bikeDetailTblVC = (BikeDetailTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDBikeDetailTblVC"];
    bikeDetailTblVC.comeFrom = @"addBike";
    [self.navigationController pushViewController:bikeDetailTblVC animated:YES];
}

- (IBAction)actionSearch:(id)sender{
    BikeSearchTableViewController *bikeSearchTblVC = (BikeSearchTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDBikeSearchTblVC"];
    bikeSearchTblVC.bike = _bike;
    [self.navigationController pushViewController:bikeSearchTblVC animated:YES];
}

-(IBAction)actionMyOrder:(id)sender{
    
}

@end
