//
//  Config.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/14.
//  Copyright © 2018年 俞健. All rights reserved.
//

#ifndef Config_h
#define Config_h
//static NSString *HTTP = @"http://10.0.176.218:20072";
static NSString *HTTP = @"http://192.168.0.105:20072";
//用户登录接口地址
static NSString *LoginHandler = @"/LoginHandler.ashx";
//用户信息接口地址
static NSString *UserHandler = @"/UserHandler.ashx";
//用户信息接口地址
static NSString *TripHandler = @"/TripHandler.ashx";
//优惠券接口地址
static NSString *CouponHandler = @"/CouponHandler.ashx";
//单车信息接口地址
static NSString *BikeHandler = @"/BikeHandler.ashx";
//报修处理
static NSString *RepairHandler = @"/RepairHandler.ashx";


#endif /* Config_h */
