//
//  TripDetailViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/23.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "TripDetailViewController.h"
#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "Config.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "Until.h"

@interface TripDetailViewController () <MAMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UILabel *lblConsume;
@property (weak, nonatomic) IBOutlet UILabel *lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTime;
@property (weak, nonatomic) IBOutlet UIView *vInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblBikeID;

//地图
@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation TripDetailViewController{
    AFHTTPSessionManager *manager;
    NSString *strURL;
    MBProgressHUD *HUD;
    NSMutableArray *listPosition;
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
    //加载背景图片
    _vInfo.layer.contents = (id)([UIImage imageNamed:@"BG"].CGImage);
    //初始化session
    manager = [AFHTTPSessionManager manager];
    strURL = [HTTP stringByAppendingString: TripHandler];
    NSData *dataPhoto   = [[NSData alloc] initWithBase64EncodedString:_user.Photo options:0];
    _imgPhoto.image = [UIImage imageWithData:dataPhoto];
    _lblPhone.text = _user.Phone;
    listPosition = [[NSMutableArray alloc] init];
    [self initMapView];
    [self initValue];
}

- (void)initMapView {
    [AMapServices sharedServices].enableHTTPS =YES;
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    [_mapView setZoomLevel:17 animated:YES];
    [self.view addSubview:_mapView];
    [self.view sendSubviewToBack:_mapView];
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

- (void)initValue{
    [self initHUD];
    NSDictionary *param = @{@"TripID":_trip.TripID,@"Type":@"detail"};
    [manager GET:strURL parameters:param progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            NSDictionary *dicTrip = [responseObject objectForKey:@"trip"];
            _lblBikeID.text = [NSString stringWithFormat:@"车牌号：%@",[dicTrip objectForKey:@"BikeID"]];
            _lblConsume.text = [NSString stringWithFormat:@"行程费用：%0.2f元",[[dicTrip objectForKey:@"Consume"] floatValue]];
            _lblStartTime.text = [dicTrip objectForKey:@"StartTime"];
            _lblEndTime.text = [dicTrip objectForKey:@"EndTime"];
            _trip.Position = [dicTrip objectForKey:@"Position"];
            if([Until isBlankString:_trip.Position]){
                //设置默认地址为南京信息工程大学滨江学院
                CLLocationCoordinate2D commonPolylineCoord = CLLocationCoordinate2DMake(32.202512, 118.705835);
                self.mapView.centerCoordinate = commonPolylineCoord;
            }
            else{
                NSArray *arrayPosition = [_trip.Position componentsSeparatedByString:@"|"];
                double Latitude = [[arrayPosition[1] componentsSeparatedByString:@","][0] doubleValue];
                double Longitude = [[arrayPosition[1] componentsSeparatedByString:@","][1] doubleValue];
                CLLocationCoordinate2D commonPolylineCoord = CLLocationCoordinate2DMake(Latitude, Longitude);
                self.mapView.centerCoordinate = commonPolylineCoord;
                for (int i=0; i<arrayPosition.count; i++) {
                    if([arrayPosition[i] isEqualToString:@""]){
                        continue;
                    }
                    NSDictionary *dicPosition = @{@"latitude":[arrayPosition[i] componentsSeparatedByString:@","][0],@"longitude":[arrayPosition[i] componentsSeparatedByString:@","][1]};
                    [listPosition addObject:dicPosition];
                }
                [self draw];
            }
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

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"加载中";
    [HUD showAnimated:YES];
}

@end
