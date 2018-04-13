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

@interface CycleViewController () <MAMapViewDelegate, AMapLocationManagerDelegate>

//地图
@property (nonatomic, strong) MAMapView *mapView;
//定位
@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

@implementation CycleViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVite];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initVite {
    [self initMapView];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leftViewShow:(id)sender {
    MenuViewController *vc = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    UINavigationController *navC = self.navigationController;
    [navC cw_showDefaultDrawerViewController:vc];
}
- (IBAction)scanning:(id)sender {
    ScanCodeViewController *scanCodeVC = [[ScanCodeViewController alloc] init];
    [[self navigationController] pushViewController:scanCodeVC animated:YES];
}

@end
