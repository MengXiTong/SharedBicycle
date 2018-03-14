//
//  LeftViewController.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/3/3.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,DrawerType) {
    DrawerDefaultLeft = 1, // 默认动画，左侧划出
    DrawerDefaultRight,    // 默认动画，右侧滑出
    DrawerTypeMaskLeft,    // 遮盖动画，左侧划出
    DrawerTypeMaskRight    // 遮盖动画，右侧滑出
};
@interface MenuViewController : UIViewController {
    //屏幕信息
    CGRect screen;
}
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblCredit;

@property (nonatomic,assign) DrawerType drawerType; // 抽屉类型
@property (nonatomic,strong) NSArray *titleArray;
@property (strong, nonatomic) UITableView *tableView;

@end
