//
//  LoginViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/3/5.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import <AFNetworking.h>
#import "Toast.h"
#import "Config.h"
#import "UserNavController.h"
#import <MBProgressHUD.h>

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblVerification;
@property (weak, nonatomic) IBOutlet UITextField *tfID;
@property (weak, nonatomic) IBOutlet UITextField *tfVerification;
@property (weak, nonatomic) IBOutlet UITextField *tfPwd;

@end

@implementation LoginViewController{
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

- (void)initView {
    //点击空白处隐藏键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    //显示记住的密码
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    self.tfID.text = [userDef stringForKey:@"ID"];
    self.tfPwd.text = [userDef stringForKey:@"Pwd"];
    //获取随机数
    self.lblVerification.text = [self getVerification];
}

- (NSString *) getVerification {
    int value = arc4random() % 900000 + 100000;
    NSString *str = [[NSString alloc] initWithFormat:@"%d",value];
    return str;
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    //隐藏键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (IBAction)login:(id)sender {
    if ([self.tfID.text isEqualToString:@""]){
        [Toast showAlertWithMessage:@"请输入登录账号" withView:self];
        return;
    }
    if ([self.tfPwd.text isEqualToString:@""]){
        [Toast showAlertWithMessage:@"请输入登录密码" withView:self];
        return;
    }
//    if(_tfVerification.text != _lblVerification.text){
//        [Toast showAlertWithMessage:@"请输入正确的验证码" withView:self];
//        return;
//    }
    //初始化加载条
    [self initHUD];
    NSString *strURL = [HTTP stringByAppendingString: LoginHandler];
    NSDictionary *param = @{@"UserID":_tfID.text,@"Passward":_tfPwd.text};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [HUD removeFromSuperview];
        if([[responseObject objectForKey:@"status"] boolValue]){
            if([[responseObject objectForKey:@"login"] boolValue]){
                //登录成功后
                NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
                [userDef setObject:self.tfID.text forKey:@"ID"];
                [userDef setObject:self.tfPwd.text forKey:@"Pwd"];
                [userDef synchronize];
                [Toast showAlertWithMessage:@"登录成功" withView:self];
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UserNavController *userNavC = (UserNavController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDNavC"];
                User *user = [[User alloc] init];
                user.UserID = _tfID.text;
                userNavC.user = user;
                [self presentViewController:userNavC animated:YES completion:^(void){
                    [[UIApplication sharedApplication] delegate].window.rootViewController = userNavC;
                    [[[UIApplication sharedApplication] delegate].window makeKeyWindow];
                }];
            }
            else{
                [Toast showAlertWithMessage:@"登录失败" withView:self];
            }
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [HUD removeFromSuperview];
        NSLog(@"LoginError: %@",error);
    }];
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"登录中";
    [HUD showAnimated:YES];
}

- (IBAction)register:(id)sender {
    
}

@end
