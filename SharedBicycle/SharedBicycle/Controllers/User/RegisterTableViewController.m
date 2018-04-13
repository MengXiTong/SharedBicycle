//
//  RegisterTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/13.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "RegisterTableViewController.h"

@interface RegisterTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblVerification;

@end

@implementation RegisterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    //去除多余的表格分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //点击空白处隐藏键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    //获取随机数
    self.lblVerification.text = [self getVerification];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    //隐藏键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (NSString *) getVerification {
    int value = arc4random() % 900000 + 100000;
    NSString *str = [[NSString alloc] initWithFormat:@"%d",value];
    return str;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
