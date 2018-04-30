//
//  RepairViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/26.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "RepairViewController.h"
#import "Until.h"
#import "Toast.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"
#import "CycleViewController.h"

@interface RepairViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btnIndex0;
@property (weak, nonatomic) IBOutlet UIButton *btnIndex1;
@property (weak, nonatomic) IBOutlet UIButton *btnIndex2;
@property (weak, nonatomic) IBOutlet UIButton *btnIndex3;
@property (weak, nonatomic) IBOutlet UIButton *btnIndex4;
@property (weak, nonatomic) IBOutlet UIButton *btnIndex5;
@property (weak, nonatomic) IBOutlet UIButton *btnIndex6;
@property (weak, nonatomic) IBOutlet UIButton *btnIndex7;

@end

@implementation RepairViewController{
    NSMutableArray *listRepairContent;
    MBProgressHUD *HUD;
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
    self.navigationItem.title = @"单车报修";
    listRepairContent = [[NSMutableArray alloc] init];
    [listRepairContent addObject:_btnIndex0];
    [listRepairContent addObject:_btnIndex1];
    [listRepairContent addObject:_btnIndex2];
    [listRepairContent addObject:_btnIndex3];
    [listRepairContent addObject:_btnIndex4];
    [listRepairContent addObject:_btnIndex5];
    [listRepairContent addObject:_btnIndex6];
    [listRepairContent addObject:_btnIndex7];
    for (int i=0; i<listRepairContent.count; i++) {
        UIButton *button = (UIButton *)listRepairContent[i];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button.layer setBorderColor:[UIColor blackColor].CGColor];
        [button.layer setBorderWidth:1];
        [button.layer setMasksToBounds:YES];
    }
}
- (IBAction)actionConfirm:(id)sender {
    NSString *strContent = [[NSString alloc] init];
    for (int i=0; i<listRepairContent.count; i++) {
        UIButton *button = (UIButton *)listRepairContent[i];
        if(button.backgroundColor == [UIColor orangeColor]){
            strContent = [strContent stringByAppendingFormat:@"%@,",button.titleLabel.text];
        }
    }
    if([Until isBlankString:strContent]){
        [Toast showAlertWithMessage:@"请至少选择一个" withView:self];
    }
    else{
        NSLog(@"%@",strContent);
        [self postRepair:strContent];
    }
}

- (void)postRepair:(NSString *)strContent{
    [self initHUD];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *strURL = [HTTP stringByAppendingString: RepairHandler];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary *param = @{@"BikeID":_trip.BikeID,@"UserID":_trip.UserID,@"RepairContent":strContent};
    CycleViewController *cycleVC = (CycleViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    [cycleVC putOverTrip:^{
        [manager POST:strURL parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if([[responseObject objectForKey:@"status"] boolValue]){
                [self.navigationController popToViewController:cycleVC animated:YES];
            }
            else{
                NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
            }
            [HUD removeFromSuperview];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"RepairError: %@",error);
            [HUD removeFromSuperview];
        }];
    }];
}

- (IBAction)actionSelect:(id)sender{
    UIButton *button = (UIButton *)sender;
    if(button.backgroundColor == [UIColor whiteColor]){
        [button setBackgroundColor:[UIColor orangeColor]];
        [button.layer setBorderWidth:0];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else{
        [button setBackgroundColor:[UIColor whiteColor]];
        [button.layer setBorderWidth:1];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"请稍等";
    [HUD showAnimated:YES];
}

@end
