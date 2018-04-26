//
//  ProfitViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/26.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "ProfitViewController.h"
#import "CommonTableViewCell.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"
#import "Toast.h"

@interface ProfitViewController ()<UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIDatePicker *dpStart;
@property (weak, nonatomic) IBOutlet UIDatePicker *dpEnd;
@property (weak, nonatomic) IBOutlet UITableView *tblShow;

@end

@implementation ProfitViewController{
    NSMutableArray *listProfit;
    AFHTTPSessionManager *manager;
    NSString *strURL;
    MBProgressHUD *HUD;
    NSDateFormatter *formatter;
    CGRect screen;
    CGRect cGRect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView{
    self.navigationItem.title = @"收益报表";
    [_tblShow registerNib:[UINib nibWithNibName:@"CommonTableViewCell" bundle:nil] forCellReuseIdentifier:@"CellIdentifierProfit"];
    _tblShow.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblShow.dataSource = self;
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: UserHandler];
    //初始化日期格式
    formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    //获取屏幕信息
    screen = [[UIScreen mainScreen] bounds];
    cGRect = CGRectMake((screen.size.width-270)/2, (screen.size.height-40)/2, 270, 40);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return listProfit.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicProfit = listProfit[indexPath.row];
    CommonTableViewCell *modelCell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifierProfit" forIndexPath:indexPath];
    modelCell.lblShow.text = [NSString stringWithFormat:@"%@：%0.2f元",[dicProfit objectForKey:@"typeName"],[[dicProfit objectForKey:@"value"] floatValue]];
    [modelCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return modelCell;
}

-(void)getProfit:(NSString *)strStartTime strEndTime:(NSString *)strEndTime{
    [self initHUD];
    NSDictionary *param = @{@"Type":@"profit",@"StartTime":strStartTime,@"EndTime":strEndTime};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            listProfit = [responseObject objectForKey:@"profitList"];
        }
        else{
            listProfit = [[NSMutableArray alloc] init];
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
            [Toast showAlertWithMessage:[responseObject objectForKey:@"message"] withView:self withCGRect:&(cGRect)];
        }
        [_tblShow reloadData];
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"ProfitError: %@",error);
        [HUD removeFromSuperview];
    }];
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"加载中";
    [HUD showAnimated:YES];
}
- (IBAction)actionConfirm:(id)sender {
    NSComparisonResult result = [_dpStart.date compare:_dpEnd.date];
    if(result == NSOrderedDescending){
        [Toast showAlertWithMessage:@"开始时间不能小于结束时间" withView:self withCGRect:&(cGRect)];
    }
    else{
        [self getProfit:[formatter stringFromDate:_dpStart.date] strEndTime:[formatter stringFromDate:_dpEnd.date]];
    }
}

@end
