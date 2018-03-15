//
//  LeftViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/3/3.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "MenuViewController.h"
#import "UIViewController+CWLateralSlide.h"
#import "MenuTableViewCell.h"

@interface MenuViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view from its nib.
}

- (void)initView {
    //加载背景图片
//    _viewMain.layer.contents = (id)([UIImage imageNamed:@"ImgMenu"].CGImage);
    NSLog(@"%f,%f",_viewMain.frame.size.width,_viewMain.frame.size.height);
    CGFloat tblY = _lblCredit.frame.origin.y+_lblCredit.frame.size.height+20;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tblY, _viewMain.frame.size.width, _viewMain.frame.size.height-tblY) style:UITableViewStylePlain];
    [_tableView registerNib:[UINib nibWithNibName:@"MenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifierMenu"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_viewMain addSubview:_tableView];
    _aryTitle = [[NSMutableArray alloc] init];
    [_aryTitle addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"我的行程",@"title",@"Order",@"icon",nil]];
    [_aryTitle addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"我的钱包",@"title",@"Wallet",@"icon",nil]];
    [_aryTitle addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"违章记录",@"title",@"Illegal",@"icon",nil]];
    [_aryTitle addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"维修处理",@"title",@"Repair",@"icon",nil]];
    [_aryTitle addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"单车信息",@"title",@"Bike",@"icon",nil]];
    [_aryTitle addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"身份认证",@"title",@"Authentication",@"icon",nil]];
    [_aryTitle addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"收益报表",@"title",@"ReportForm",@"icon",nil]];
//    screen = [[UIScreen mainScreen] bounds];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _aryTitle.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierMenu"];
    cell.lblName.text = [_aryTitle[indexPath.row] objectForKey:@"title"];
    cell.imgIcon.image = [UIImage imageNamed:[_aryTitle[indexPath.row] objectForKey:@"icon"]];
    return cell;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect rect = self.view.frame;
    
    switch (_drawerType) {
        case DrawerDefaultLeft:
            [self.view.superview sendSubviewToBack:self.view];
            break;
        case DrawerTypeMaskLeft:
            rect.size.width = CGRectGetWidth(self.view.frame) * 0.75;
            break;
        default:
            break;
    }
    
    self.view.frame = rect;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
