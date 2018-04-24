//
//  BikeDetailTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "BikeDetailTableViewController.h"
#import "BikeTableViewController.h"
#import "ModelTableViewController.h"
#import "StateTableViewController.h"
#import "Until.h"
#import "Toast.h"
#import <AFNetworking.h>
#import <MBProgressHUD.h>
#import "Config.h"

@interface BikeDetailTableViewController ()

@end

@implementation BikeDetailTableViewController{
    BikeTableViewController *bikeTblVC;
    AFHTTPSessionManager *manager;
    NSString *strURL;
    MBProgressHUD *HUD;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardHide:(UITapGestureRecognizer*)tap{
    //隐藏键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (void)initView{
    //点击空白处隐藏键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    bikeTblVC = (BikeTableViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    if([_comeFrom isEqualToString:@"updateBike"]){
        [_btnSave setTitle:@"更新" forState:UIControlStateNormal];
        [_btnDelete setTitle:@"删除" forState:UIControlStateNormal];
        _tfBikeID.text = _bike.BikeID;
        _tfLatitude.text = _bike.BikeLatitude;
        _tfLongitude.text = _bike.BikeLongitude;
        _lblState.text = _bike.StateName;
        _lblModel.text = _bike.ModelName;
        self.navigationItem.title = @"单车信息详情";
    }
    else if([_comeFrom isEqualToString:@"addBike"]){
        [_btnSave setTitle:@"新增" forState:UIControlStateNormal];
        [_btnDelete setTitle:@"取消" forState:UIControlStateNormal];
        _lblState.text = @"";
        _lblModel.text = @"";
        self.navigationItem.title = @"新增单车信息";
        _bike = [[Bike alloc] init];
    }
    //初始化Session
    manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    strURL = [HTTP stringByAppendingString: BikeHandler];
}

- (void)putBike{
    [self initHUD];
    NSDictionary *param = @{@"BikeID":_bike.BikeID,@"ModelID":_bike.ModelID,@"StateID":_bike.StateID,@"BikeLongitude":_bike.BikeLongitude,@"BikeLatitude":_bike.BikeLatitude};
    [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            [Toast showAlertWithMessage:@"更新成功" withView:self];
            [bikeTblVC loadNewData];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"BikeDetailError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (void)deleteBike{
    [self initHUD];
    manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
    NSDictionary *param = @{@"BikeID":_bike.BikeID};
    [manager DELETE:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            [Toast showAlertWithMessage:@"删除成功" withView:self];
            [bikeTblVC loadNewData];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"BikeDetailError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (void)postBike{
    [self initHUD];
    NSDictionary *param = @{@"BikeID":_bike.BikeID,@"ModelID":_bike.ModelID,@"StateID":_bike.StateID,@"BikeLongitude":_bike.BikeLongitude,@"BikeLatitude":_bike.BikeLatitude};
    [manager POST:strURL parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            [Toast showAlertWithMessage:@"新增成功" withView:self];
            [bikeTblVC loadNewData];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
            [Toast showAlertWithMessage:[responseObject objectForKey:@"message"] withView:self];
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"BikeDetailError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (BOOL)isComplete{
    [self keyboardHide:nil];
    if([Until isBlankString:_tfBikeID.text]){
        [Toast showAlertWithMessage:@"请填写车牌号" withView:self];
        return NO;
    }
    if([Until isBlankString:_bike.StateID]){
        [Toast showAlertWithMessage:@"请选择状态" withView:self];
        return NO;
    }
    if([Until isBlankString:_bike.ModelID]){
        [Toast showAlertWithMessage:@"请选择车型" withView:self];
        return NO;
    }
    if([Until isBlankString:_tfLongitude.text]){
        [Toast showAlertWithMessage:@"请填写经度" withView:self];
        return NO;
    }
    if([Until isBlankString:_tfLatitude.text]){
        [Toast showAlertWithMessage:@"请填写纬度" withView:self];
        return NO;
    }
    _bike.BikeID = _tfBikeID.text;
    _bike.BikeLongitude = _tfLongitude.text;
    _bike.BikeLatitude = _tfLatitude.text;
    return YES;
}

- (IBAction)actionBtnSave:(id)sender {
    if([_comeFrom isEqualToString:@"updateBike"]){
        if([self isComplete]){
            [self putBike];
        }
    }
    else if([_comeFrom isEqualToString:@"addBike"]){
        if([self isComplete]){
            [self postBike];
        }
    }
}

- (IBAction)actionBtnDetele:(id)sender {
    if([_comeFrom isEqualToString:@"updateBike"]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定删除吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self deleteBike];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:confirmAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if([_comeFrom isEqualToString:@"addBike"]){
        [self.navigationController popToViewController:bikeTblVC animated:true];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 1:{
            ModelTableViewController *modelTblVC = [[ModelTableViewController alloc] init];
            modelTblVC.bike = _bike;
            modelTblVC.comeFrom = @"bikeDetail";
            [self.navigationController pushViewController:modelTblVC animated:YES];
            break;
        }
        case 2:{
            StateTableViewController *stateTblVC = [[StateTableViewController alloc] init];
            stateTblVC.bike = _bike;
            stateTblVC.comeFrom = @"bikeDetail";
            [self.navigationController pushViewController:stateTblVC animated:YES];
            break;
        }
        default:
            break;
    }
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"请稍等";
    [HUD showAnimated:YES];
}

@end
