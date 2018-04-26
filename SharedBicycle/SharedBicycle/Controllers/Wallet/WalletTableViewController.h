//
//  WalletTableViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface WalletTableViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *lblBalance;
@property (nonatomic, strong) User *user;
@property (weak, nonatomic) IBOutlet UILabel *lblCoupon;
@property (weak, nonatomic) IBOutlet UILabel *lblDeposit;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDeposit;

@end
