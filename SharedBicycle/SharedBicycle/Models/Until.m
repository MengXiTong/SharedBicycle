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
    //6-16位数字和字母组成
    NSString *regex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,16}$";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:passWord];
}

+ (BOOL)checkUserName : (NSString *) userName
{
    //正则匹配用户姓名,2-20位的中文或英文
    NSString *regex = @"^[a-zA-Z\u4E00-\u9FA5]{2,20}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:userName];
}

+ (BOOL)checkUserID : (NSString *) userID
{
    //正则匹配用户账号,2-10位的数字或者字母
    NSString *regex = @"^[0-9A-Za-z]{2,10}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:userID];
}

+ (BOOL)checkMoney : (NSString *) money
{
    NSString *regex = @"^\\d{1,3}+(\\.\\d{1,2})?$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:money];
}

+ (NSString *)getPhotoString:(UIImage *) imgPhoto isNeedCompress:(BOOL) isNeedCompress{
    NSData *data = nil;
    if(isNeedCompress){
        data = UIImageJPEGRepresentation(imgPhoto, 0.01);
    }
    else{
        data = UIImageJPEGRepresentation(imgPhoto, 1.0);
    }
    return [data base64EncodedStringWithOptions:0];;
}

+ (NSDateComponents *)getDateComponents : (NSDate *)startDate WithEndDate:(NSDate *)endDate{
    NSCalendar *calender=[NSCalendar currentCalendar];
    NSCalendarUnit unitsave=NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *comps = [calender components:unitsave fromDate:startDate toDate:endDate options:0];
    return comps;
}

+ (NSString *)numberFormatter: (NSInteger *)num{
    if(num>9){
        return [[NSString alloc] initWithFormat:@"%ld",num];
    }
    else{
        return [[NSString alloc] initWithFormat:@"0%ld",num];
    }
}

+ (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+(void)setKeyboardHide:(UIView *)view{
    //点击空白处隐藏键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [view addGestureRecognizer:tapGestureRecognizer];
}

+(void)keyboardHide:(UITapGestureRecognizer*)tap{
    //隐藏键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end
