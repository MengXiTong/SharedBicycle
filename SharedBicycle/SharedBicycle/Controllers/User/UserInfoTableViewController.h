//
//  UserInfoTableViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/11.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserInfoTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *lblShowPhone;
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditScore;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblSex;
@property (weak, nonatomic) IBOutlet UILabel *lblBirthday;
@property (weak, nonatomic) IBOutlet UILabel *lblIdentity;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellBirthday;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSex;

@property (nonatomic, strong) User *user;

@end
