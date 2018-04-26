//
//  RepairTableViewCell.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/26.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RepairTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblBikeID;
@property (weak, nonatomic) IBOutlet UILabel *lblUser;
@property (weak, nonatomic) IBOutlet UILabel *lblState;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblRepairUserID;

@end
