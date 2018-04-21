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

+ (BOOL)checkPhone:(NSString *) phone;
+ (BOOL)checkPassWord:(NSString *) passWord;
+ (BOOL)checkUserName:(NSString *) userName;
+ (BOOL)checkUserID : (NSString *) userID;
+ (NSString *)getPhotoString:(UIImage *) imgPhoto isNeedCompress:(BOOL) isNeedCompress;
+ (NSDateComponents *)getDateComponents : (NSDate *)startDate WithEndDate:(NSDate *)endDate;
+ (NSString *)numberFormatter: (NSInteger *)num;

@end
