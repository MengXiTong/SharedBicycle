//
//  UpdateUserViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/17.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "UpdateUserViewController.h"
#import "Toast.h"
#import "Until.h"
#import <MBProgressHUD.h>
#import "Config.h"
#import <AFNetworking.h>
#import "UserInfoTableViewController.h"

@interface UpdateUserViewController ()

@end

@implementation UpdateUserViewController{
    CGRect cGRect;
    CGRect screen;
    MBProgressHUD *HUD;
    AFHTTPSessionManager *manager;
    NSString *strURL;
    UserInfoTableViewController *userInfoTblVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)initView {
    [Until setKeyboardHide:self.view];
    userInfoTblVC = (UserInfoTableViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    //获取屏幕信息
    screen = [[UIScreen mainScreen] bounds];
    cGRect = CGRectMake((screen.size.width-200)/2, (screen.size.height-40)/2, 200, 40);
    if([_type isEqualToString:@"name"]){
        [_tfUpdateAgain setHidden:YES];
        _lblholder.text = @"2-20个字符，仅支持中文或英文";
        _tfUpdate.placeholder = @"请输入您的新名字";
        _tfUpdate.keyboardType = UIKeyboardTypeDefault;
        self.navigationItem.title = @"修改姓名";
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(actionSaveName:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    else if([_type isEqualToString:@"phone"]){
        [_tfUpdateAgain setHidden:YES];
        _lblholder.text = @"11个字符，仅以13/14/15/17/18开头的数字字符";
        _tfUpdate.placeholder = @"请输入您的新手机号";
        _tfUpdate.keyboardType = UIKeyboardTypeNumberPad;
        self.navigationItem.title = @"修改手机号";
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(actionSavePhone:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    else if([_type isEqualToString:@"pwd"]){
        [_tfUpdateAgain setHidden:NO];
        _lblholder.text = @"6-16位数字和字母组成的字符";
        _tfUpdate.placeholder = @"请输入您的新密码";
        _tfUpdate.keyboardType = UIKeyboardTypeASCIICapable;
        _tfUpdate.secureTextEntry = YES;
        _tfUpdateAgain.placeholder = @"再次请输入您的密码";
        _tfUpdateAgain.keyboardType = UIKeyboardTypeASCIICapable;
        _tfUpdateAgain.secureTextEntry = YES;
        self.navigationItem.title = @"修改密码";
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(actionSavePwd:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    //初始化Session
    manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    strURL = [HTTP stringByAppendingString: UserHandler];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionSaveName:(id)sender{
    [Until keyboardHide:nil];
    if([Until checkUserName:_tfUpdate.text]){
        _user.Name = _tfUpdate.text;
        [self putName];
    }
    else{
        [Toast showAlertWithMessage:@"姓名格式错误" withView:self withCGRect:&(cGRect)];
    }
}

- (IBAction)actionSavePhone:(id)sender{
    [Until keyboardHide:nil];
    if([Until checkPhone:_tfUpdate.text]){
        _user.Phone = _tfUpdate.text;
        [self putPhone];
    }
    else{
        [Toast showAlertWithMessage:@"手机号码格式错误" withView:self withCGRect:&(cGRect)];
    }
}

- (IBAction)actionSavePwd:(id)sender{
    [Until keyboardHide:nil];
    if([Until checkPassWord:_tfUpdate.text]){
        if([_tfUpdate.text isEqualToString:_tfUpdateAgain.text]){
            _user.Passward = _tfUpdate.text;
            [self putPwd];
        }
        else{
            [Toast showAlertWithMessage:@"两次输入密码不一致" withView:self withCGRect:&(cGRect)];
        }
    }
    else{
        [Toast showAlertWithMessage:@"密码格式错误" withView:self withCGRect:&(cGRect)];
    }
}

- (void)putName{
    [self initHUD];
    NSDictionary *user = @{@"UserID":_user.UserID,@"Name":_user.Name};
    NSDictionary *param = @{@"type":@"name",@"user":user};
    [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            userInfoTblVC.lblName.text = _user.Name;
            [Toast showAlertWithMessage:@"更新姓名成功" withView:self];
            [self.navigationController popToViewController:userInfoTblVC animated:true];
        }
        else{
            [Toast showAlertWithMessage:@"更新姓名失败" withView:self];
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [HUD removeFromSuperview];
        NSLog(@"UserInfoError: %@",error);
    }];
}

- (void)putPhone{
    [self initHUD];
    NSDictionary *user = @{@"UserID":_user.UserID,@"Phone":_user.Phone};
    NSDictionary *param = @{@"type":@"phone",@"user":user};
    [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            userInfoTblVC.lblPhone.text = _user.Phone;
            [Toast showAlertWithMessage:@"更新手机号成功" withView:self];
            [self.navigationController popToViewController:userInfoTblVC animated:true];
        }
        else{
            [Toast showAlertWithMessage:@"更新手机号失败" withView:self];
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [HUD removeFromSuperview];
        NSLog(@"UserInfoError: %@",error);
    }];
}

- (void)putPwd{
    [self initHUD];
    NSDictionary *user = @{@"UserID":_user.UserID,@"Passward":_user.Passward};
    NSDictionary *param = @{@"type":@"passward",@"user":user};
    [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            [Toast showAlertWithMessage:@"更新密码成功" withView:self];
            NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
            [userDef setObject:_user.UserID forKey:@"ID"];
            [userDef setObject:_user.Passward forKey:@"Pwd"];
            [userDef synchronize];
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *indexNavC= (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDIndexNavC"];
            [self presentViewController:indexNavC animated:YES completion:nil];
            
        }
        else{
            [Toast showAlertWithMessage:@"更新密码失败" withView:self];
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [HUD removeFromSuperview];
        NSLog(@"UserInfoError: %@",error);
    }];
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"请稍等";
    [HUD showAnimated:YES];
}

@end
