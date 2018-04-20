//
//  Trip.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/20.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Trip : NSObject
@property (nonatomic, retain) NSString *TripID;
@property (nonatomic, retain) NSString *UserID;
@property (nonatomic, retain) NSString *BikeID;
@property (nonatomic, retain) NSString *StartTime;
@property (nonatomic, retain) NSString *EndTime;
@property (nonatomic, retain) NSString *Consume;
@property (nonatomic, retain) NSString *Position;
@property (nonatomic, retain) NSString *State;
@property (nonatomic, retain) NSString *CouponID;
@end
