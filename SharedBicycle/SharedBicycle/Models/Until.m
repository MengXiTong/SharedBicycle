//
//  Until.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/17.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "Until.h"

@implementation Until

+ (BOOL)checkPhone:(NSString *)phone
{
    //手机号以13/14/15/17/18开头 9个 \d 数字字符
    NSString *regex = @"^1+[34578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:phone];
}

+ (BOOL)checkPassWord:(NSString *)passWord
{
    //6-20位数字和字母组成
    NSString *regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,20}$";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:passWord];
}

+ (BOOL)checkUserName : (NSString *) userName
{
    //正则匹配用户姓名,4-20位的中文或英文
    NSString *regex = @"^[a-zA-Z\u4E00-\u9FA5]{4,20}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:userName];
}

@end
