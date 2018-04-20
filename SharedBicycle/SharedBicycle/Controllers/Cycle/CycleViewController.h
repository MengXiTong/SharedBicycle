//
//  ViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/2/23.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Trip.h"

@interface CycleViewController : UIViewController {
    
}

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Trip *trip;
@property (weak, nonatomic) IBOutlet UIView *vScan;
@property (weak, nonatomic) IBOutlet UIView *vInUse;
@property (weak, nonatomic) IBOutlet UIView *vPay;
@property (weak, nonatomic) IBOutlet UILabel *lblUseTime;
@property (weak, nonatomic) IBOutlet UILabel *lblUseMoney;
@property (weak, nonatomic) IBOutlet UILabel *lblPayReal;
@property (weak, nonatomic) IBOutlet UILabel *lblPayTotal;
@property (weak, nonatomic) IBOutlet UILabel *lblPayCoupon;

@end

