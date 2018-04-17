//
//  Toast.m
//  Greenwz
//
//  Created by 老猫 on 2017/8/31.
//  Copyright © 2017年 老猫. All rights reserved.
//

#import "Toast.h"

@implementation Toast

//显示提示信息，类似android中的toast
+ (void)showAlertWithMessage:(NSString *)message withView:(UIViewController *)container{
    CGRect screen = [[UIScreen mainScreen] bounds];
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:CGRectMake((screen.size.width-160)/2, 400, 160, 40)];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.textColor = [UIColor whiteColor];
    hintLabel.backgroundColor = [UIColor blackColor];
    hintLabel.alpha = 0.0;
    hintLabel.text = message;
    [container.view addSubview:hintLabel];
    //animateWithDuration可以控制label显示持续时间
    [UIView animateWithDuration:1.0 animations:^{
        hintLabel.alpha = 1.0;
    } completion:^(BOOL finished){
        [hintLabel removeFromSuperview];
    }];
}

+ (void)showAlertWithMessage:(NSString *)message withView:(UIViewController *)container withCGRect:(CGRect *) cGRect{
    UILabel *hintLabel = [[UILabel alloc] initWithFrame:*cGRect];
    hintLabel.textAlignment = NSTextAlignmentCenter;
    hintLabel.textColor = [UIColor whiteColor];
    hintLabel.backgroundColor = [UIColor blackColor];
    hintLabel.alpha = 0.0;
    hintLabel.text = message;
    [container.view addSubview:hintLabel];
    //animateWithDuration可以控制label显示持续时间
    [UIView animateWithDuration:1.0 animations:^{
        hintLabel.alpha = 1.0;
    } completion:^(BOOL finished){
        [hintLabel removeFromSuperview];
    }];
}

@end
