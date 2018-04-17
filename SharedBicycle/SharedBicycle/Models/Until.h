//
//  Until.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/17.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Until : NSObject

+ (BOOL)checkPhone:(NSString *) phone;
+ (BOOL)checkPassWord:(NSString *) passWord;
+ (BOOL)checkUserName:(NSString *) userName;

@end
