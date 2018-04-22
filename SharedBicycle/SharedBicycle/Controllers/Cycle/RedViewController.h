//
//  RedViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/22.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface RedViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imgBg;
@property (weak, nonatomic) IBOutlet UILabel *lblHide;
@property (weak, nonatomic) IBOutlet UIButton *btnLook;
@property (weak, nonatomic) IBOutlet UIButton *btnOpen;
@property (weak, nonatomic) IBOutlet UILabel *lblCouponTypeName;

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) User *user;

@end
