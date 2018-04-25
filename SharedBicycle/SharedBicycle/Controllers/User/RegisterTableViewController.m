//
//  RegisterTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/13.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "RegisterTableViewController.h"
#import "Until.h"
#import <MBProgressHUD.h>
#import "Config.h"
#import <AFNetworking.h>
#import "Toast.h"
#import "UserNavController.h"
#import "User.h"
#import <TZImagePickerController.h>

@interface RegisterTableViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblVerification;
@property (weak, nonatomic) IBOutlet UITextField *tfUserID;
@property (weak, nonatomic) IBOutlet UITextField *tfPwd;
@property (weak, nonatomic) IBOutlet UITextField *tfPwdAgain;
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UILabel *lblSex;
@property (weak, nonatomic) IBOutlet UILabel *lblBirthday;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfVerification;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellBirthday;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSex;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation RegisterTableViewController{
    MBProgressHUD *HUD;
    AFHTTPSessionManager *manager;
    NSString *strURL;
    UIAlertController *alertBirthday;
    UIAlertController *alertSex;
    UIAlertController *alertPhoto;
    NSDateFormatter *formatter;
    CGRect screen;
    CGRect cGRect;
    User *user;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    //初始化用户类
    [self initValue];
    //获取屏幕信息
    screen = [[UIScreen mainScreen] bounds];
    cGRect = CGRectMake((screen.size.width-270)/2, (screen.size.height-40)/2, 270, 40);
    //初始化日期格式
    formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    //去除多余的表格分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //点击空白处隐藏键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    //获取随机数
    self.lblVerification.text = [self getVerification];
    //初始化Session
    manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    strURL = [HTTP stringByAppendingString: UserHandler];
    //初始化点击事件
    _imgPhoto.userInteractionEnabled = YES;
    [_imgPhoto addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionImgPhoto:)]];
    //初始化时间选择器
    [self initDatePicker];
    //初始化性别选择器
    [self initSexPicker];
    //初始化头像选择器
    [self initPhotoPicker];
}

- (void)initValue{
    user = [[User alloc] init];
    user.Sex = @"true";
    user.Birthday = @"";
    user.Photo = @"";
    _lblSex.text = @"男";
}

- (void)keyboardHide:(UITapGestureRecognizer*)tap{
    //隐藏键盘
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

- (NSString *) getVerification {
    int value = arc4random() % 900000 + 100000;
    NSString *str = [[NSString alloc] initWithFormat:@"%d",value];
    return str;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 5:
            [self presentViewController:alertSex animated:YES completion:nil];
            break;
        case 6:
            [self presentViewController:alertBirthday animated:YES completion:nil];
            break;
        default:
            break;
    }
}

- (void)initDatePicker
{
    UIDatePicker *dpBirthday = [[UIDatePicker alloc] initWithFrame:CGRectMake(18, 15, screen.size.width*0.85, 167)];
    dpBirthday.datePickerMode = UIDatePickerModeDate;//时间模式的选择 有多种
//    NSDate *date = [formatter dateFromString:self.lblBirthday.text];
//    dpBirthday.date = date;
    //用自定义的UIAlertController选择ActionShee信息模式  并将中间的信息显示范围空出来 高度自由指定
    alertBirthday = [UIAlertController alertControllerWithTitle:nil message:@"\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertBirthday.view addSubview:dpBirthday];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        user.Birthday = [formatter stringFromDate:dpBirthday.date];
        _lblBirthday.text = user.Birthday;
        [self.cellBirthday setSelected:NO animated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.cellBirthday setSelected:NO animated:YES];
    }];
    [alertBirthday addAction:confirmAction];
    [alertBirthday addAction:cancelAction];
}

-(void)initSexPicker{
    alertSex = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *manAction = [UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.cellSex setSelected:NO animated:YES];
        user.Sex = @"true";
        _lblSex.text = @"男";
    }];
    UIAlertAction *womanAction = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.cellSex setSelected:NO animated:YES];
        user.Sex = @"false";
        _lblSex.text = @"女";
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.cellSex setSelected:NO animated:YES];
    }];
    [alertSex addAction:manAction];
    [alertSex addAction:womanAction];
    [alertSex addAction:cancelAction];
}

-(void)initPhotoPicker{
    alertPhoto = [[UIAlertController alloc] init];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self takingPictuers];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        TZImagePickerController *imagePickerVC = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    [alertPhoto addAction:photoAction];
    [alertPhoto addAction:albumAction];
    [alertPhoto addAction:cancelAction];
}

//拍照
- (void)takingPictuers {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePickerController.delegate = self;
        self.imagePickerController.allowsEditing = YES;
        // 设置相机模式
        self.imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        // 设置摄像头：前置/后置
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        // 设置闪光模式
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        // 推送图片拾取器控制器
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }else {
        NSLog(@"当前设备不支持拍照");
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"当前设备不支持拍照" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

//相机拍照代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera && [info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        user.Photo = [Until getPhotoString:info[UIImagePickerControllerOriginalImage] isNeedCompress:YES];
        _imgPhoto.image = info[UIImagePickerControllerOriginalImage];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//相机拍照取消代理
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//相册选择照片代理
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    user.Photo = [Until getPhotoString:[photos objectAtIndex:0] isNeedCompress:NO];
    _imgPhoto.image = [photos objectAtIndex:0];
}

- (void)postUser{
    [self initHUD];
    NSDictionary *param = @{@"UserID":_tfUserID.text,
                            @"Passward":_tfPwd.text,
                            @"Name":_tfName.text,
                            @"Sex":user.Sex,
                            @"Birthday":user.Birthday,
                            @"Phone":_tfPhone.text,
                            @"Photo":user.Photo};
    [manager POST:strURL parameters:param progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if([[responseObject objectForKey:@"status"] boolValue]){
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UserNavController *userNavC = (UserNavController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDNavC"];
            User *user = [[User alloc] init];
            user.UserID = _tfUserID.text;
            userNavC.user = user;
            [self presentViewController:userNavC animated:YES completion:^(void){
                [[UIApplication sharedApplication] delegate].window.rootViewController = userNavC;
                [[[UIApplication sharedApplication] delegate].window makeKeyWindow];
                [Toast showAlertWithMessage:@"注册成功" withView:userNavC];
            }];
        }
        else{
            [Toast showAlertWithMessage:[responseObject objectForKey:@"message"] withView:self];
            NSLog(@"ServiceError: %@",[responseObject objectForKey:@"message"]);
        }
        [HUD removeFromSuperview];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [HUD removeFromSuperview];
        NSLog(@"RegisterError: %@",error);
    }];
}

- (IBAction)actionBtnRegister:(id)sender {
    if(![Until checkUserID:_tfUserID.text]){
        [Toast showAlertWithMessage:@"账号2-10位的数字或者字母组成" withView:self withCGRect:&(cGRect)];
        return;
    }
    if(![Until checkPassWord:_tfPwd.text]){
        [Toast showAlertWithMessage:@"密码6-16位数字和字母混合组成" withView:self withCGRect:&(cGRect)];
        return;
    }
    if(![_tfPwd.text isEqualToString:_tfPwdAgain.text]){
        [Toast showAlertWithMessage:@"两次密码不一致" withView:self];
        return;
    }
    if(![Until checkUserName:_tfName.text]){
        [Toast showAlertWithMessage:@"姓名2-20位的中文或者英文组成" withView:self withCGRect:&(cGRect)];
        return;
    }
    if(![Until checkPhone:_tfPhone.text]){
        [Toast showAlertWithMessage:@"手机号码格式错误" withView:self];
        return;
    }
    if(![_tfVerification.text isEqualToString:_lblVerification.text]){
        [Toast showAlertWithMessage:@"验证码错误" withView:self];
        return;
    }
    [self postUser];
}

- (IBAction)actionImgPhoto:(id)sender {
    [self presentViewController:alertPhoto animated:YES completion:nil];
}

//初始化加载条
- (void)initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.label.text = @"请稍等";
    [HUD showAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
