//
//  UpdateUserViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/17.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UpdateUserViewController : UIViewController

@property (nonatomic, strong) NSString *type;
@property (weak, nonatomic) IBOutlet UITextField *tfUpdate;
@property (weak, nonatomic) IBOutlet UILabel *lblholder;
@property (weak, nonatomic) IBOutlet UITextField *tfUpdateAgain;

@property (nonatomic, strong) User *user;

@end
