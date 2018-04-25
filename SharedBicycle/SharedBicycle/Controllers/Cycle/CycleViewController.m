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
#import "RedViewController.h"
#import "CouponTableViewController.h"

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
    //更新当前时间
    NSTimer *timer;
    //更新位置
    NSTimer *updateTimer;
    int count;
    NSDateFormatter *formatter;
    NSDateComponents *comps;
    NSMutableArray *listPosition;
    NSMutableArray *listBikePosition;
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
    //初始化位置数组
    listPosition = [[NSMutableArray alloc] init];
    //初始化优惠券点击事件
    _lblPayCoupon.userInteractionEnabled = YES;
    [_lblPayCoupon addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionCoupon:)]];
    [self initMap];
    [self initSource];
    [self initUserInfo];
    [self initTripState];
    [self initBikePosition];
}

- (IBAction)actionCoupon:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CouponTableViewController *couponTblVC = (CouponTableViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDCouponTblVC"];
    couponTblVC.user = _user;
    couponTblVC.type = @"select";
    [self.navigationController pushViewController:couponTblVC animated:YES];
}

-(void)initSource{
    [self initHUD];
    count = 0;
    source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(source, ^{
        if(dispatch_source_get_data(source)==3){
            [HUD removeFromSuperview];
        }
    });
    dispatch_resume(source);
}

- (void)takeUse {
    [self getCurrentTime];
    [self getCurrentPosition];
    if(comps.day>0){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您已违规超时" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"结束用车" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self putOverTrip];
        }];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(getCurrentTime) userInfo:nil repeats:YES];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:8.0 target:self selector:@selector(getCurrentPosition) userInfo:nil repeats:YES];
}

- (void)getCurrentTime{
    comps = [Until getDateComponents:[formatter dateFromString:_trip.StartTime] WithEndDate:[NSDate date]];
    self.lblUseTime.text = [[NSString alloc] initWithFormat:@"%@:%@:%@",[Until numberFormatter:comps.hour],[Until numberFormatter:comps.minute],[Until numberFormatter:comps.second]];
    if(comps.day>0){
        _trip.Consume = @"24.0";
    }
    else if(comps.minute>=5){
        _trip.Consume = [NSString stringWithFormat:@"%ld.0",comps.hour+1];
    }
    else{
        _trip.Consume = [NSString stringWithFormat:@"%ld.0",comps.hour];
    }
    _lblUseMoney.text = _trip.Consume;
}

- (void)getCurrentPosition{
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
        NSDictionary *dicPosition = @{@"latitude":[NSString stringWithFormat:@"%f",location.coordinate.latitude],@"longitude":[NSString stringWithFormat:@"%f",location.coordinate.longitude]};
        [listPosition addObject:dicPosition];
        [self putPosition:[NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude]];
        [self draw];
    }];
}

- (void)draw{
    CLLocationCoordinate2D commonPolylineCoords[listPosition.count];
    for(int i=0;i<listPosition.count;i++){
        commonPolylineCoords[i].longitude = [[listPosition[i] objectForKey:@"longitude"] doubleValue];
        commonPolylineCoords[i].latitude = [[listPosition[i] objectForKey:@"latitude"] doubleValue];
    }
    MAPolyline *commonPolyline = [MAPolyline polylineWithCoordinates:commonPolylineCoords count:listPosition.count];
    [_mapView addOverlay: commonPolyline];
}

- (void)initMap{
    [AMapServices sharedServices].enableHTTPS =YES;
    //地图配置
    [self initMapView];
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

//设置折线属性
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.lineWidth = 8.f;
        polylineRenderer.strokeColor = [UIColor greenColor];
        return polylineRenderer;
    }
    return nil;
}

- (void)initUserInfo {
    UserNavController *userNavC = (UserNavController *)self.navigationController;
    _user = userNavC.user;
    NSString *strURL = [HTTP stringByAppendingString: UserHandler];
    NSDictionary *param = @{@"UserID":self.user.UserID,@"Type":@"user"};
    //[AFHTTPRequestSerializer serializer]这是默认编码格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
        dispatch_source_merge_data(source, ++count);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"UserError: %@",error);
        dispatch_source_merge_data(source, ++count);
    }];
}

- (void)initTripState{
    _trip = [[Trip alloc] init];
    NSString *strURL = [HTTP stringByAppendingString: TripHandler];
    NSDictionary *param = @{@"UserID":self.user.UserID,@"Type":@"state"};
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
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
            if(![Until isBlankString:_trip.Position]){
                NSArray *arrayPosition = [_trip.Position componentsSeparatedByString:@"|"];
                for (int i=0; i<arrayPosition.count; i++) {
                    if([arrayPosition[i] isEqualToString:@""]){
                        continue;
                    }
                    NSDictionary *dicPosition = @{@"latitude":[arrayPosition[i] componentsSeparatedByString:@","][0],@"longitude":[arrayPosition[i] componentsSeparatedByString:@","][1]};
                    [listPosition addObject:dicPosition];
                }
                [self draw];
            }
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
        dispatch_source_merge_data(source, ++count);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"TripError: %@",error);
        dispatch_source_merge_data(source, ++count);
    }];
}

- (void)initBikePosition {
    NSString *strURL = [HTTP stringByAppendingString: BikeHandler];
    NSDictionary *param = @{@"Type":@"bike",@"SubType":@"position"};
    //[AFHTTPRequestSerializer serializer]这是默认编码格式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            listBikePosition = [responseObject objectForKey:@"bikeList"];
            [self drawBikePosition];
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        dispatch_source_merge_data(source, ++count);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"UserError: %@",error);
        dispatch_source_merge_data(source, ++count);
    }];
}

- (void)drawBikePosition{
    for (int i=0; i<listBikePosition.count; i++) {
        MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
        double Latitude = [[listBikePosition[i] objectForKey:@"BikeLatitude"] doubleValue];
        double Longitude = [[listBikePosition[i] objectForKey:@"BikeLongitude"] doubleValue];
        pointAnnotation.coordinate = CLLocationCoordinate2DMake(Latitude, Longitude);
        [_mapView addAnnotation:pointAnnotation];
    }
}

- (void)putOverTrip{
    [self initHUD];
    _trip.EndTime = [formatter stringFromDate:[NSDate date]];
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        NSString *strURL = [HTTP stringByAppendingString: TripHandler];
        NSDictionary *trip = @{@"TripID":_trip.TripID,@"Position":[NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude],@"BikeID":_trip.BikeID,@"Consume":_trip.Consume,@"EndTime":_trip.EndTime,@"StartTime":_trip.StartTime,@"UserID":_user.UserID};
        NSDictionary *param = @{@"type":@"end",@"trip":trip};
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if([[responseObject objectForKey:@"status"] boolValue]){
                [Toast showAlertWithMessage:@"结束行程成功" withView:self];
                _trip.State = @"defray";
                [timer invalidate];
                timer = nil;
                [updateTimer invalidate];
                updateTimer = nil;
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
        if (error.code == AMapLocationErrorLocateFailed)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            CGRect cGRect = CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, ([[UIScreen mainScreen] bounds].size.height-40)/2, 200, 40);
            [Toast showAlertWithMessage:@"定位失败，请重新确认" withView:self withCGRect:&cGRect];
            [HUD removeFromSuperview];
            return;
        }
        if (location)
        {
            NSString *strURL = [HTTP stringByAppendingString: TripHandler];
            NSDictionary *trip = [[NSDictionary alloc] init];
            if([Until isBlankString:_trip.CouponID]){
                trip = @{@"TripID":_trip.TripID,@"UserID":_trip.UserID,@"Consume":_lblPayReal.text};
            }
            else{
                trip = @{@"TripID":_trip.TripID,@"UserID":_trip.UserID,@"Consume":_lblPayReal.text,@"CouponID":_trip.CouponID};
            }
            NSDictionary *param = @{@"type":@"pay",@"trip":trip};
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if([[responseObject objectForKey:@"status"] boolValue]){
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    RedViewController *redVC = (RedViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDRedVC"];
                    if([_lblPayReal.text floatValue]>=1){
                        redVC.type = @"show";
                    }
                    else{
                        redVC.type = @"over";
                    }
                    redVC.type = @"show";
                    redVC.user = _user;
                    [self.navigationController pushViewController:redVC animated:YES];
                    _trip.State = @"finish";
                    [_mapView removeFromSuperview];
                    [self initMapView];
                    [self drawBikePosition];
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
        }
    }];
}

- (void)putPosition:(NSString *)strPosition{
    NSString *strURL = [HTTP stringByAppendingString: TripHandler];
    NSDictionary *trip = @{@"TripID":_trip.TripID,@"Position":strPosition,@"State":_trip.State};
    NSDictionary *param = @{@"type":@"position",@"trip":trip};
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager PUT:strURL parameters:param success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSLog(@"ServiceInfo: 更新位置成功");
        }
        else{
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"TripError: %@",error);
    }];
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
    if(_user){
        ScanCodeViewController *scanCodeVC = [[ScanCodeViewController alloc] init];
        scanCodeVC.user = _user;
        [[self navigationController] pushViewController:scanCodeVC animated:YES];
    }
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
    [updateTimer invalidate];
    updateTimer = nil;
}

@end
