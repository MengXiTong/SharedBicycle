//
//  CouponTableViewCell.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/23.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblExpirationDate;
@property (weak, nonatomic) IBOutlet UILabel *lblFavorablePrice;

@end
