//
//  LeftViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/3/3.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

typedef NS_ENUM(NSUInteger,DrawerType) {
    DrawerDefaultLeft = 1, // 默认动画，左侧划出
    DrawerDefaultRight,    // 默认动画，右侧滑出
    DrawerTypeMaskLeft,    // 遮盖动画，左侧划出
    DrawerTypeMaskRight    // 遮盖动画，右侧滑出
};
@interface MenuViewController : UIViewController {
}
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblCredit;

@property (nonatomic, strong) NSMutableArray *aryTitle;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) User *user;

@end
