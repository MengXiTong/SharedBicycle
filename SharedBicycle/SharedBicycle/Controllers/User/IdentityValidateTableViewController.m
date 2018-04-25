//
//  IdentityValidateTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/25.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "IdentityValidateTableViewController.h"
#import "Config.h"
#import <AFNetworking.h>
#import "Toast.h"
#import "Until.h"
#import <MBProgressHUD.h>
#import "IdentityTableViewController.h"

@interface IdentityValidateTableViewController ()

@end

@implementation IdentityValidateTableViewController{
    MBProgressHUD *HUD;
    AFHTTPSessionManager *manager;
    NSString *strURL;
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
    self.navigationItem.title = @"身份认证";
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self setHide:YES];
    [Until setKeyboardHide:self.view];
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: UserHandler];
}

- (void)setHide:(BOOL)isHide{
    [_cellPhoto setHidden:isHide];
    [_cellName setHidden:isHide];
    [_cellSex setHidden:isHide];
    [_cellBirthday setHidden:isHide];
    [_cellPhone setHidden:isHide];
    [_cellIdentity setHidden:isHide];
    [_cellAction setHidden:isHide];
}

- (void)getUserInfo {
    [self initHUD];
    NSDictionary *param = @{@"UserID":_user.UserID,@"Type":@"user"};
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSDictionary *dicUser = [responseObject objectForKey:@"user"];
            _user.IdentityID = [dicUser objectForKey:@"IdentityID"];
            _lblIdentity.text = [dicUser objectForKey:@"IdentityName"];
            _lblName.text = [dicUser objectForKey:@"Name"];
            _lblSex.text = [[dicUser objectForKey:@"Sex"] boolValue]?@"男":@"女";
            _lblPhone.text = [dicUser objectForKey:@"Phone"];
            NSData *dataPhoto   = [[NSData alloc] initWithBase64EncodedString:[dicUser objectForKey:@"Photo"] options:0];
            _imgPhoto.image = [UIImage imageWithData:dataPhoto];
            [self setHide:NO];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
            [Toast showAlertWithMessage:[responseObject objectForKey:@"message"] withView:self];
            [self setHide:YES];
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"IdentityValidateError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (void)putIdentity{
    [self initHUD];
    NSDictionary *user = @{@"UserID":_user.UserID,@"IdentityID":_user.IdentityID};
    NSDictionary *param = @{@"type":@"identity",@"user":user};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            [Toast showAlertWithMessage:@"认证身份成功" withView:self];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"IdentityValidateError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (IBAction)actionSelect:(id)sender {
    [Until keyboardHide:nil];
    if(![Until isBlankString:_tfUserID.text]){
        _user = [[User alloc] init];
        _user.UserID = _tfUserID.text;
        [self getUserInfo];
    }
    else{
        [Toast showAlertWithMessage:@"请输入查询账号" withView:self];
    }
}
- (IBAction)actionConfirm:(id)sender {
    [self putIdentity];
}
- (IBAction)actionCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 6){
        IdentityTableViewController *identityTblVC = [[IdentityTableViewController alloc] init];
        identityTblVC.user = _user;
        [self.navigationController pushViewController:identityTblVC animated:YES];
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
