//
//  Until.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/17.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Until : NSObject

//手机号验证
+ (BOOL)checkPhone:(NSString *) phone;
//密码验证
+ (BOOL)checkPassWord:(NSString *) passWord;
//用户名验证
+ (BOOL)checkUserName:(NSString *) userName;
//账号验证
+ (BOOL)checkUserID : (NSString *) userID;
//金额验证
+ (BOOL)checkMoney : (NSString *) money;
//图片转字符串
+ (NSString *)getPhotoString:(UIImage *) imgPhoto isNeedCompress:(BOOL) isNeedCompress;
//获取两个时间的差
+ (NSDateComponents *)getDateComponents : (NSDate *)startDate WithEndDate:(NSDate *)endDate;
//修改数字格式
+ (NSString *)numberFormatter: (NSInteger *)num;
//判断字符串是否为空
+ (BOOL) isBlankString:(NSString *)string;

+(void)setKeyboardHide:(UIView *)view;

+(void)keyboardHide:(UITapGestureRecognizer*)tap;

@end
