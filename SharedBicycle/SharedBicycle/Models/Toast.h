//
//  Toast.h
//  Greenwz
//
//  Created by 老猫 on 2017/8/31.
//  Copyright © 2017年 老猫. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Toast : NSObject

//显示提示信息，类似android中的toast
+ (void)showAlertWithMessage:(NSString *)message withView:(id)sender;

//自定义
+ (void)showAlertWithMessage:(NSString *)message withView:(id)sender withCGRect:(CGRect *) cGRect;

@end
