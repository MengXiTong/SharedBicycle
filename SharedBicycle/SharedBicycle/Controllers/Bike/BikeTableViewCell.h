//
//  BikeTableViewCell.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/24.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BikeTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblBikeID;
@property (weak, nonatomic) IBOutlet UILabel *lblModel;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UILabel *lblPosition;

@end
