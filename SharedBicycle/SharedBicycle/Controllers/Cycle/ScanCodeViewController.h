//
//  SGQRCodeViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/3/16.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ShadowView.h"
#import "User.h"

#define kWidth [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define customShowSize CGSizeMake(200, 200);

@interface ScanCodeViewController : UIViewController

@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *comeFrom;

@end
