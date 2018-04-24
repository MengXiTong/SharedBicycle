//
//  BikeSearchTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "BikeSearchTableViewController.h"
#import "StateTableViewController.h"
#import "ModelTableViewController.h"
#import "BikeTableViewController.h"

@interface BikeSearchTableViewController ()

@end

@implementation BikeSearchTableViewController{
    BikeTableViewController *bikeTblVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView{
    self.navigationItem.title = @"单车查询";
    //点击空白处隐藏键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    _lblModel.text = _bike.ModelName;
    _lblState.text = _bike.StateName;
    _tfBikeID.text = _bike.BikeID;
    bikeTblVC = (BikeTableViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)keyboardHide:(UITapGestureRecognizer*)tap{
    //隐藏键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 1:{
            ModelTableViewController *modelTblVC = [[ModelTableViewController alloc] init];
            modelTblVC.bike = _bike;
            modelTblVC.comeFrom = @"bikeSearch";
            [self.navigationController pushViewController:modelTblVC animated:YES];
            break;
        }
        case 2:{
            StateTableViewController *stateTblVC = [[StateTableViewController alloc] init];
            stateTblVC.bike = _bike;
            stateTblVC.comeFrom = @"bikeSearch";
            [self.navigationController pushViewController:stateTblVC animated:YES];
            break;
        }
        default:
            break;
    }
}

- (IBAction)actionBtnContain:(id)sender {
    _bike.BikeID = _tfBikeID.text;
    [bikeTblVC loadNewData];
    [self.navigationController popToViewController:bikeTblVC animated:true];
}

- (IBAction)actionBtnClear:(id)sender {
    _bike.BikeID = @"";
    _bike.ModelName = @"";
    _bike.ModelID = @"";
    _bike.StateName = @"";
    _bike.StateID = @"";
    _tfBikeID.text = @"";
    _lblModel.text = @"";
    _lblState.text = @"";
    [bikeTblVC loadNewData];
}

@end
