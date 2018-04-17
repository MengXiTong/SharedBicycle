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

@interface UpdateUserViewController ()

@end

@implementation UpdateUserViewController{
    CGRect cGRect;
    CGRect screen;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
}

- (void)initView {
    //获取屏幕信息
    screen = [[UIScreen mainScreen] bounds];
    cGRect = CGRectMake((screen.size.width-200)/2, (screen.size.height-40)/2, 200, 40);
    if([_type isEqualToString:@"name"]){
        _lblholder.text = @"4-20个字符，仅支持中文或英文";
        _tfUpdate.placeholder = @"请输入您的新名字";
        _tfUpdate.keyboardType = UIKeyboardTypeDefault;
        self.navigationItem.title = @"修改姓名";
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(actionSaveName:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    else if([_type isEqualToString:@"phone"]){
        _lblholder.text = @"6-20个字符，仅支持数字和字母组成";
        _tfUpdate.placeholder = @"请输入您的新手机号";
        _tfUpdate.keyboardType = UIKeyboardTypeNumberPad;
        self.navigationItem.title = @"修改手机号";
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(actionSavePhone:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionSaveName:(id)sender{
    if([Until checkUserName:_tfUpdate.text]){
        _user.Phone = _tfUpdate.text;
    }
    else{
        [Toast showAlertWithMessage:@"姓名格式错误" withView:self withCGRect:&(cGRect)];
    }
}

- (IBAction)actionSavePhone:(id)sender{
    if([Until checkPhone:_tfUpdate.text]){
        _user.Phone = _tfUpdate.text;
    }
    else{
        [Toast showAlertWithMessage:@"手机号码格式错误" withView:self withCGRect:&(cGRect)];
    }
}

@end
