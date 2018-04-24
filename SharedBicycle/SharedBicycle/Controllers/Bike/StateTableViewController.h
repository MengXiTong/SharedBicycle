//
//  StateTableViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bike.h"

@interface StateTableViewController : UITableViewController

@property (nonatomic, strong) NSString *comeFrom;
@property (nonatomic, strong) Bike *bike;

@end
