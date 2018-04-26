//
//  AchieveBikeViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/26.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "AchieveBikeViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "ScanCodeViewController.h"

@interface AchieveBikeViewController ()<MAMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *vScan;

//地图
@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation AchieveBikeViewController{
    
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
    self.navigationItem.title = @"回收报修车辆";
    //加载背景图片
    _vScan.layer.contents = (id)([UIImage imageNamed:@"BG"].CGImage);
    //初始化地图
    [self initMapView];
    [self drawBikePosition];
}

- (void)initMapView {
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    [_mapView setZoomLevel:17 animated:YES];
    [_mapView setUserTrackingMode:MAUserTrackingModeFollow  animated:YES];
    _mapView.showsCompass = NO;
    _mapView.showsScale = YES;
    _mapView.pausesLocationUpdatesAutomatically = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        _mapView.allowsBackgroundLocationUpdates = YES;
    }
    [self.view addSubview:_mapView];
    [self.view sendSubviewToBack:_mapView];
}

- (void)drawBikePosition{
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake([_bike.BikeLatitude doubleValue], [_bike.BikeLongitude doubleValue]);
    [_mapView addAnnotation:pointAnnotation];
}

- (IBAction)actionScan:(id)sender {
    if(_user){
        ScanCodeViewController *scanCodeVC = [[ScanCodeViewController alloc] init];
        scanCodeVC.user = _user;
        scanCodeVC.comeFrom = @"repair";
        [[self navigationController] pushViewController:scanCodeVC animated:YES];
    }
}

@end
