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
#import "Until.h"
#import "Toast.h"

@interface CycleViewController () <MAMapViewDelegate, AMapLocationManagerDelegate>

//地图
@property (nonatomic, strong) MAMapView *mapView;
//定位
@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

@implementation CycleViewController{
    MBProgressHUD *HUD;
    dispatch_source_t source;
    AFHTTPSessionManager *manager;
    NSTimer *timer;
    int count;
    NSDateFormatter *formatter;
    NSDateComponents *comps;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)initView {
    //加载背景图片
    _vInUse.layer.contents = (id)([UIImage imageNamed:@"BG"].CGImage);
    _vScan.layer.contents = (id)([UIImage imageNamed:@"BG"].CGImage);
    _vPay.layer.contents = (id)([UIImage imageNamed:@"BG"].CGImage);
    //初始化session
    manager = [AFHTTPSessionManager manager];
    //初始化时间格式
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [self initMapView];
    [self initSource];
    [self initUserInfo];
    [self initTripState];
}

- (void)initUserInfo {
    UserNavController *userNavC = (UserNavController *)self.navigationController;
    _user = userNavC.user;
    NSString *strURL = [HTTP stringByAppendingString: UserHandler];
    NSDictionary *param = @{@"UserID":self.user.UserID};
    //[AFHTTPRequestSerializer serializer]这是默认编码格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_source_merge_data(source, ++count);
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSDictionary *dicUser = [responseObject objectForKey:@"user"];
            _user.UserID = [dicUser objectForKey:@"UserID"];
            _user.Passward = [dicUser objectForKey:@"Passward"];
            _user.Name = [dicUser objectForKey:@"Name"];
            _user.Sex = [dicUser objectForKey:@"Sex"];
            _user.Birthday = [dicUser objectForKey:@"Birthday"];
            _user.IdentityID = [dicUser objectForKey:@"IdentityID"];
            _user.IdentityName = [dicUser objectForKey:@"IdentityName"];
            _user.Phone = [dicUser objectForKey:@"Phone"];
            _user.CreditScore = [dicUser objectForKey:@"CreditScore"];
            _user.Photo = [dicUser objectForKey:@"Photo"];
            _user.Balance = [dicUser objectForKey:@"Balance"];
            _user.Deposit = [dicUser objectForKey:@"Deposit"];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"UserError: %@",error);
        dispatch_source_merge_data(source, ++count);
    }];
}

-(void)initSource{
    [self initHUD];
    count = 0;
    source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(source, ^{
        if(dispatch_source_get_data(source)==2){
            [HUD removeFromSuperview];
        }
    });
    dispatch_resume(source);
}

- (void)initTripState{
    _trip = [[Trip alloc] init];
    NSString *strURL = [HTTP stringByAppendingString: TripHandler];
    NSDictionary *param = @{@"UserID":self.user.UserID};
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_source_merge_data(source, ++count);
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSDictionary *dicTrip = [responseObject objectForKey:@"trip"];
            _trip.State = [dicTrip objectForKey:@"State"];
            _trip.TripID = [dicTrip objectForKey:@"TripID"];
            _trip.UserID = [dicTrip objectForKey:@"UserID"];
            _trip.BikeID = [dicTrip objectForKey:@"BikeID"];
            _trip.StartTime = [dicTrip objectForKey:@"StartTime"];
            _trip.EndTime = [dicTrip objectForKey:@"EndTime"];
            _trip.Consume = [dicTrip objectForKey:@"Consume"];
            _trip.Position = [dicTrip objectForKey:@"Position"];
            if([_trip.State isEqual:@"finish"]){
                [_vInUse setHidden:YES];
                [_vPay setHidden:YES];
                [_vScan setHidden:NO];
            }
            else if([_trip.State isEqual:@"defray"]){
                _lblPayTotal.text = [NSString stringWithFormat:@"总费用：%0.1f元",[_trip.Consume floatValue]];
                _lblPayReal.text = [NSString stringWithFormat:@"%0.2f",[_trip.Consume floatValue]];
                [_vInUse setHidden:YES];
                [_vPay setHidden:NO];
                [_vScan setHidden:YES];
            }
            else if([_trip.State isEqual:@"unfinish"]){
                [_vInUse setHidden:NO];
                [_vPay setHidden:YES];
                [_vScan setHidden:YES];
                [self takeUse];
            }
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"TripError: %@",error);
        dispatch_source_merge_data(source, ++count);
    }];
}

- (void)putOverTrip{
    [self initHUD];
    _trip.EndTime = [formatter stringFromDate:[NSDate date]];
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        NSString *strURL = [HTTP stringByAppendingString: TripHandler];
        NSDictionary *trip = @{@"TripID":_trip.TripID,@"Position":[NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude],@"BikeID":_trip.BikeID,@"Consume":_trip.Consume,@"EndTime":_trip.EndTime};
        NSDictionary *param = @{@"type":@"end",@"trip":trip};
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if([[responseObject objectForKey:@"status"] boolValue]){
                if(timer){
                    [timer invalidate];
                    timer = nil;
                }
                _lblPayTotal.text = [NSString stringWithFormat:@"总费用：%0.1f元",[_trip.Consume floatValue]];
                _lblPayReal.text = [NSString stringWithFormat:@"%0.2f",[_trip.Consume floatValue]];
                [_vInUse setHidden:YES];
                [_vPay setHidden:NO];
                [_vScan setHidden:YES];
            }
            else{
                NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
            }
            [HUD removeFromSuperview];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"TripError: %@",error);
            [HUD removeFromSuperview];
        }];
    }];
}

- (void)putPay{
    [self initHUD];
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        NSString *strURL = [HTTP stringByAppendingString: TripHandler];
        NSDictionary *trip = @{@"TripID":_trip.TripID,@"UserID":_trip.UserID,@"Consume":_trip.Consume,@"EndTime":_trip.EndTime,@"StartTime":_trip.StartTime};
        NSDictionary *param = @{@"type":@"pay",@"trip":trip};
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if([[responseObject objectForKey:@"status"] boolValue]){
                [Toast showAlertWithMessage:@"支付成功" withView:self];
                [_vInUse setHidden:YES];
                [_vPay setHidden:YES];
                [_vScan setHidden:NO];
            }
            else{
                NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
            }
            [HUD removeFromSuperview];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"TripError: %@",error);
            [HUD removeFromSuperview];
        }];
    }];
}

- (void)takeUse {
    [self getCurrentTime];
    if(comps.day>0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您已违规超时" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"结束用车" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self putOverTrip];
        }];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getCurrentTime) userInfo:nil repeats:YES];
}

- (void)getCurrentTime{
    comps = [Until getDateComponents:[formatter dateFromString:_trip.StartTime] WithEndDate:[NSDate date]];
    self.lblUseTime.text = [[NSString alloc] initWithFormat:@"%@:%@:%@",[Until numberFormatter:comps.hour],[Until numberFormatter:comps.minute],[Until numberFormatter:comps.second]];
    if(comps.day>0){
        _trip.Consume = @"24.0";
    }
    else if(comps.minute>5){
        _trip.Consume = [NSString stringWithFormat:@"%ld.0",comps.hour+1];
    }
    else{
        _trip.Consume = [NSString stringWithFormat:@"%ld.0",comps.hour];
    }
    _lblUseMoney.text = _trip.Consume;
}

- (void)initMapView {
    [AMapServices sharedServices].enableHTTPS =YES;
    //地图配置
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    [self.view addSubview:_mapView];
    [self.view sendSubviewToBack:_mapView];
    _mapView.showsUserLocation = YES;
    [_mapView setZoomLevel:17 animated:YES];
    [_mapView setUserTrackingMode:MAUserTrackingModeFollow  animated:YES];
    _mapView.showsCompass = NO;
    _mapView.showsScale = YES;
    _mapView.pausesLocationUpdatesAutomatically = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        _mapView.allowsBackgroundLocationUpdates = YES;
    }
    //定位配置
    _locationManager = [[AMapLocationManager alloc] init];
    _locationManager.delegate = self;
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    self.locationManager.locationTimeout =2;
    self.locationManager.reGeocodeTimeout = 2;
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    }];
}

- (void)startUpdatingLocation{
    [self.locationManager startUpdatingLocation];
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
    scanCodeVC.user = _user;
    [[self navigationController] pushViewController:scanCodeVC animated:YES];
}
- (IBAction)overTrip:(id)sender {
    [self putOverTrip];
}
- (IBAction)pay:(id)sender {
    [self putPay];
}

- (void)dealloc {
    [timer invalidate];
    timer = nil;
}

@end
