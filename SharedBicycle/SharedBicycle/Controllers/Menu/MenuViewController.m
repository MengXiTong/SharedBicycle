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
#import "UserInfoTableViewController.h"
#import "TripTableViewController.h"

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
    [self initMenu];
    NSData *dataPhoto   = [[NSData alloc] initWithBase64EncodedString:_user.Photo options:0];
    _imgHead.image = [UIImage imageWithData:dataPhoto];
    //添加查看个人信息点击事件
    _imgHead.userInteractionEnabled = YES;
    [_imgHead addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionImgHead:)]];
    NSString *strPhone = [[NSString alloc] initWithFormat:@"%@****%@",[_user.Phone substringToIndex:3],[_user.Phone substringFromIndex:7]];
    _lblPhone.text = strPhone;
    _lblCredit.text = [[NSString alloc] initWithFormat:@"已认证.信用分%@",_user.CreditScore];
}

- (void) initMenu{
    CGFloat tblY = _lblCredit.frame.origin.y+_lblCredit.frame.size.height+20;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tblY, self.view.frame.size.width, self.view.frame.size.height-tblY) style:UITableViewStylePlain];
    [_tableView registerNib:[UINib nibWithNibName:@"MenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifierMenu"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    _aryTitle = [[NSMutableArray alloc] init];
    [_aryTitle addObject:@{@"title":@"我的行程",@"icon":@"Order",@"storyID":@"storyIDTripTblVC"}];
    [_aryTitle addObject:@{@"title":@"我的钱包",@"icon":@"Wallet",@"storyID":@"storyIDTripTblVC"}];
    [_aryTitle addObject:@{@"title":@"违章记录",@"icon":@"Illegal",@"storyID":@"storyIDTripTblVC"}];
    [_aryTitle addObject:@{@"title":@"维修处理",@"icon":@"Repair",@"storyID":@"storyIDTripTblVC"}];
    [_aryTitle addObject:@{@"title":@"单车信息",@"icon":@"Bike",@"storyID":@"storyIDTripTblVC"}];
    [_aryTitle addObject:@{@"title":@"身份认证",@"icon":@"Authentication",@"storyID":@"storyIDTripTblVC"}];
    [_aryTitle addObject:@{@"title":@"收益报表",@"icon":@"ReportForm",@"storyID":@"storyIDTripTblVC"}];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dicTitle = _aryTitle[indexPath.row];
    if([(NSString *)[dicTitle objectForKey:@"storyID"] isEqualToString:@"storyIDTripTblVC"]){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        TripTableViewController *tripTblVC = (TripTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDTripTblVC"];
        tripTblVC.user = _user;
        [self cw_pushViewController:tripTblVC];
        return;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect rect = self.view.frame;
    rect.size.width = CGRectGetWidth(self.view.frame) * 0.75;
    self.view.frame = rect;
}

- (IBAction)actionImgHead:(id)sender {
    NSLog(@"dasdasdasd");
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserInfoTableViewController *userInfoTblVC = (UserInfoTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDUserInfoTblVC"];
    userInfoTblVC.user = _user;
    [self cw_pushViewController:userInfoTblVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
