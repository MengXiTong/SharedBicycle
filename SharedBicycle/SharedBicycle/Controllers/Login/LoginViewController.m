//
//  LoginViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/3/5.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblVerification;
@property (weak, nonatomic) IBOutlet UITextField *txtVerification;
@property (weak, nonatomic) IBOutlet UITextField *txtID;
@property (weak, nonatomic) IBOutlet UITextField *txtPwd;

@end

@implementation LoginViewController

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
//    if(_txtVerification.text == _lblVerification.text){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *navC = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDNavC"];
        //登录成功后
        [self presentViewController:navC animated:YES completion:^(void){
            [[UIApplication sharedApplication] delegate].window.rootViewController = navC;
            [[[UIApplication sharedApplication] delegate].window makeKeyWindow];
        }];
//    }
}

- (IBAction)register:(id)sender {
    
}

@end
