//
//  BikeSearchTableViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bike.h"

@interface BikeSearchTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *tfBikeID;
@property (weak, nonatomic) IBOutlet UILabel *lblModel;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (nonatomic, strong) Bike *bike;

@end
