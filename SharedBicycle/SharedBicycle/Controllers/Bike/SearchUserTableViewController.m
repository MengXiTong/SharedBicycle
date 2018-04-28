//
//  SearchUserTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/28.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "SearchUserTableViewController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"
#import "Toast.h"

@interface SearchUserTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblUserID;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellUserID;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTime;

@end

@implementation SearchUserTableViewController{
    UIAlertController *alertTime;
    NSDateFormatter *formatter;
    CGRect screen;
    CGRect cGRect;
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

- (void)initView{
    //获取屏幕信息
    screen = [[UIScreen mainScreen] bounds];
    cGRect = CGRectMake((screen.size.width-270)/2, (screen.size.height-40)/2, 270, 40);
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //初始化日期格式
    formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    [_cellUserID setHidden:YES];
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: TripHandler];
    [self initDatePicker];
}
- (IBAction)actionSelect:(id)sender {
    if([_lblTime.text isEqualToString:@"请选择时间"]){
        [Toast showAlertWithMessage:@"请选择时间" withView:self];
    }
    else{
        [self getUserID];
    }
}

-(void)getUserID{
    [self initHUD];
    NSDictionary *param = @{@"Type":@"lastUser",@"BikeID":_bike.BikeID,@"Time":_lblTime.text};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSDictionary *dicTrip = [responseObject objectForKey:@"trip"];
            _lblUserID.text = [dicTrip objectForKey:@"UserID"];
            [_cellUserID setHidden:NO];
        }
        else{
            [_cellUserID setHidden:YES];
            [Toast showAlertWithMessage:[responseObject objectForKey:@"message"] withView:self withCGRect:&(cGRect)];
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"SearchUserError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (void)initDatePicker
{
    UIDatePicker *dpTime = [[UIDatePicker alloc] initWithFrame:CGRectMake(18, 15, screen.size.width*0.85, 167)];
    dpTime.datePickerMode = UIDatePickerModeDateAndTime;//时间模式的选择 有多种
    //用自定义的UIAlertController选择ActionShee信息模式  并将中间的信息显示范围空出来 高度自由指定
    alertTime = [UIAlertController alertControllerWithTitle:nil message:@"\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertTime.view addSubview:dpTime];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _lblTime.text = [formatter stringFromDate:dpTime.date];
        [self.cellTime setSelected:NO animated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.cellTime setSelected:NO animated:YES];
    }];
    [alertTime addAction:confirmAction];
    [alertTime addAction:cancelAction];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 1:
            [self presentViewController:alertTime animated:YES completion:nil];
            break;
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
