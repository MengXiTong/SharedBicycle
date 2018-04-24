//
//  BikeDetailTableViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bike.h"

@interface BikeDetailTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UITextField *tfBikeID;
@property (weak, nonatomic) IBOutlet UILabel *lblModel;
@property (weak, nonatomic) IBOutlet UITextField *tfLongitude;
@property (weak, nonatomic) IBOutlet UITextField *tfLatitude;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (nonatomic, strong) Bike *bike;
@property (nonatomic, strong) NSString *comeFrom;

@end
