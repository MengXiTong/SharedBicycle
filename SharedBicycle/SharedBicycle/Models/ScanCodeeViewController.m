//
//  SGQRCodeViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/3/16.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "ScanCodeViewController.h"

@interface ScanCodeViewController () <AVCaptureMetadataOutputObjectsDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/** 输入数据源 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/** 输出数据源 */
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
/** 输入输出的中间桥梁 负责把捕获的音视频数据输出到输出设备中 */
@property (nonatomic, strong) AVCaptureSession *session;
/** 相机拍摄预览图层 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *layerView;
/** 预览图层尺寸 */
@property (nonatomic, assign) CGSize layerViewSize;
/** 有效扫码范围 */
@property (nonatomic, assign) CGSize showSize;
/** 自定义的View视图 */
@property (nonatomic, strong) ShadowView *shadowView;

@end

@implementation ScanCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //显示范围
    self.showSize = customShowSize;
    //调用
    [self creatScanQR];
    //添加拍摄图层
    [self.view.layer addSublayer:self.layerView];
    //开始二维码
    [self.session startRunning];
    //设置可用扫码范围
    [self allowScanRect];
    //添加上层阴影视图
    self.shadowView = [[ShadowView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight - 64)];
    [self.view addSubview:self.shadowView];
    self.shadowView.showSize = self.showSize;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)creatScanQR{
    /** 创建输入数据源 */
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];  //获取摄像设备
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];  //创建输出流
    
    /** 创建输出数据源 */
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];  //设置代理 在主线程里刷新
    
    /** Session设置 */
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];   //高质量采集
    [self.session addInput:self.input];
    [self.session addOutput:self.output];
    //设置扫码支持的编码格式
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                        AVMetadataObjectTypeEAN13Code,
                                        AVMetadataObjectTypeEAN8Code,
                                        AVMetadataObjectTypeCode128Code];
    /** 扫码视图 */
    //扫描框的位置和大小
    self.layerView = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.layerView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.layerView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64);
    // 将扫描框大小定义为属行, 下面会有调用
    self.layerViewSize = CGSizeMake(_layerView.frame.size.width, _layerView.frame.size.height);
    
}

#pragma mark - 实现代理方法, 完成二维码扫描
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count > 0) {
        
        // 停止动画, 看完全篇记得打开注释, 不然扫描条会一直有动画效果
        [self.shadowView removeAnimationAboutScan];
        
        //停止扫描
        [self.session stopRunning];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        //输出扫描字符串
        NSLog(@"%@",metadataObject.stringValue);
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@", metadataObject.stringValue] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

/** 配置扫码范围 */
-(void)allowScanRect{
    
    
    /** 扫描是默认是横屏, 原点在[右上角]
     *  rectOfInterest = CGRectMake(0, 0, 1, 1);
     *  AVCaptureSessionPresetHigh = 1920×1080   摄像头分辨率
     *  需要转换坐标 将屏幕与 分辨率统一
     */
    
    //剪切出需要的大小位置
    CGRect shearRect = CGRectMake((self.layerViewSize.width - self.showSize.width) / 2,
                                  (self.layerViewSize.height - self.showSize.height) / 2,
                                  self.showSize.height,
                                  self.showSize.height);
    
    
    CGFloat deviceProportion = 1920.0 / 1080.0;
    CGFloat screenProportion = self.layerViewSize.height / self.layerViewSize.width;
    
    //分辨率比> 屏幕比 ( 相当于屏幕的高不够)
    if (deviceProportion > screenProportion) {
        //换算出 分辨率比 对应的 屏幕高
        CGFloat finalHeight = self.layerViewSize.width * deviceProportion;
        // 得到 偏差值
        CGFloat addNum = (finalHeight - self.layerViewSize.height) / 2;
        
        // (对应的实际位置 + 偏差值)  /  换算后的屏幕高
        self.output.rectOfInterest = CGRectMake((shearRect.origin.y + addNum) / finalHeight,
                                                shearRect.origin.x / self.layerViewSize.width,
                                                shearRect.size.height/ finalHeight,
                                                shearRect.size.width/ self.layerViewSize.width);
        
    }else{
        
        CGFloat finalWidth = self.layerViewSize.height / deviceProportion;
        
        CGFloat addNum = (finalWidth - self.layerViewSize.width) / 2;
        
        self.output.rectOfInterest = CGRectMake(shearRect.origin.y / self.layerViewSize.height,
                                                (shearRect.origin.x + addNum) / finalWidth,
                                                shearRect.size.height / self.layerViewSize.height,
                                                shearRect.size.width / finalWidth);
    }
    
}

@end
