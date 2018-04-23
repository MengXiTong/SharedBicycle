//
//  TripDetailViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/23.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "TripDetailViewController.h"

@interface TripDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblConsume;
@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTime;
@property (weak, nonatomic) IBOutlet UIView *vInfo;

@end

@implementation TripDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
