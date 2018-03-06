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

@property (nonatomic,strong) NSArray *titleArray;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view from its nib.
}

- (void)initView {
    //加载背景图片
    _viewMain.layer.contents = (id)([UIImage imageNamed:@"ImgMenu"].CGImage);
    NSLog(@"%f,%f",_viewMain.frame.size.width,_viewMain.frame.size.height);
    CGFloat tblY = _imgHead.frame.origin.y+_imgHead.frame.size.height+20;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tblY, _viewMain.frame.size.width, _viewMain.frame.size.height-tblY) style:UITableViewStylePlain];
    [_tableView registerNib:[UINib nibWithNibName:@"MenuTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifierMenu"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_viewMain addSubview:_tableView];
    _titleArray = @[@"present下一个界面",@"Push下一个界面",@"Push下一个界面",@"Push下一个界面",@"显示alertView",@"主动收起抽屉"];
//    screen = [[UIScreen mainScreen] bounds];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierMenu"];
    cell.lblName.text = _titleArray[indexPath.row];
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
