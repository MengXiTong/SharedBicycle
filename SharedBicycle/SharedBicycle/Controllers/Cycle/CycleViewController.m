//
//  ViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/2/23.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "CycleViewController.h"
#import "MenuViewController.h"
#import <AFNetworking.h>
#import <UIViewController+CWLateralSlide.h>
#import "ScanCodeViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "Config.h"
#import "UserNavController.h"
#import <MBProgressHUD.h>

@interface CycleViewController () <MAMapViewDelegate, AMapLocationManagerDelegate>

//地图
@property (nonatomic, strong) MAMapView *mapView;
//定位
@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

@implementation CycleViewController{
    MBProgressHUD *HUD;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initView {
    [self initMapView];
    [self initUserInfo];
}

- (void)initUserInfo {
    [self initHUD];
    UserNavController *userNavC = (UserNavController *)self.navigationController;
    _user = userNavC.user;
    NSString *strURL = [HTTP stringByAppendingString: UserHandler];
    NSDictionary *param = @{@"UserID":self.user.UserID};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if(responseObject){
            _user.UserID = [responseObject objectForKey:@"UserID"];
            _user.Passward = [responseObject objectForKey:@"Passward"];
            _user.Name = [responseObject objectForKey:@"Name"];
            _user.Sex = [responseObject objectForKey:@"Sex"];
            _user.Birthday = [responseObject objectForKey:@"Birthday"];
            _user.IdentityID = [responseObject objectForKey:@"IdentityID"];
            _user.IdentityName = [responseObject objectForKey:@"IdentityName"];
            _user.Phone = [responseObject objectForKey:@"Phone"];
            _user.CreditScore = [responseObject objectForKey:@"CreditScore"];
            _user.Photo = [responseObject objectForKey:@"Photo"];
            _user.Balance = [responseObject objectForKey:@"Balance"];
            _user.Deposit = [responseObject objectForKey:@"Deposit"];
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"LoginError: %@",error);
        [HUD removeFromSuperview];
    }];
}

- (void)initMapView {
    [AMapServices sharedServices].enableHTTPS =YES;
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    [self.view sendSubviewToBack:_mapView];
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    [_mapView setZoomLevel:17 animated:YES];
    //地图跟着位置和方向移动
    [_mapView setUserTrackingMode:MAUserTrackingModeFollow  animated:YES];
    _mapView.showsCompass = NO;
    //后台定位 可持久记录位置信息。高德地图iOS SDK V2.5.0版本提供后台持续定位的能力，即便你的app退到后台，且位置不变动时，也不会被系统挂起，可持久记录位置信息。该功能适用于记轨迹录或者出行类App司机端。
    _mapView.pausesLocationUpdatesAutomatically = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        _mapView.allowsBackgroundLocationUpdates = YES;
    }
    _locationManager = [[AMapLocationManager alloc] init];
    _locationManager.delegate = self;
    //iOS 9（不包含iOS 9） 之前设置允许后台定位参数，保持不会被系统挂起
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    //iOS 9（包含iOS 9）之后新特性：将允许出现这种场景，同一app中多个locationmanager：一些只能在前台定位，另一些可在后台定位，并可随时禁止其后台定位。
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    [self.locationManager setLocatingWithReGeocode:YES];
}

- (void)startUpdatingLocation{
    [self.locationManager startUpdatingLocation];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"加载中";
    [HUD showAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leftViewShow:(id)sender {
    MenuViewController *vc = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    vc.user = self.user;
    [self cw_showDefaultDrawerViewController:vc];
}
- (IBAction)scanning:(id)sender {
    ScanCodeViewController *scanCodeVC = [[ScanCodeViewController alloc] init];
    [[self navigationController] pushViewController:scanCodeVC animated:YES];
}

@end
