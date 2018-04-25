//
//  BikeTableViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bike.h"
#import "User.h"

@interface BikeTableViewController : UITableViewController

@property (nonatomic, strong) Bike *bike;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *comeFrom;

- (void)loadNewData;

@end
