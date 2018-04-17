//
//  UserInfoTableViewController.m
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/11.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import "UserInfoTableViewController.h"
#import "UpdateUserViewController.h"
#import <TZImagePickerController.h>

@interface UserInfoTableViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblShowPhone;
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblCreditScore;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblSex;
@property (weak, nonatomic) IBOutlet UILabel *lblBirthday;
@property (weak, nonatomic) IBOutlet UILabel *lblIdentity;
@property (weak, nonatomic) IBOutlet UILabel *lblPhone;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellBirthday;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSex;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation UserInfoTableViewController{
    UIAlertController *alertBirthday;
    UIAlertController *alertSex;
    UIAlertController *alertPhoto;
    NSDateFormatter *formatter;
    CGRect screen;
    UIStoryboard *storyboard;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)initView {
    //获取屏幕信息
    screen = [[UIScreen mainScreen] bounds];
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //初始化日期格式
    formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    //去除多余的表格分割线
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //初始化导航栏
    [self initValue];
    //初始化时间选择器
    [self initDatePicker];
    //初始化性别选择器
    [self initSexPicker];
    //初始化头像选择器
    [self initPhotoPicker];
}

- (void)initValue{
    self.navigationItem.title = @"个人信息";
    NSData *dataPhoto   = [[NSData alloc] initWithBase64EncodedString:_user.Photo options:0];
    _imgPhoto.image = [UIImage imageWithData:dataPhoto];
    _imgPhoto.userInteractionEnabled = YES;
    [_imgPhoto addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionImgPhoto:)]];
    NSString *strPhone = [[NSString alloc] initWithFormat:@"%@****%@",[_user.Phone substringToIndex:3],[_user.Phone substringFromIndex:7]];
    _lblPhone.text = strPhone;
    _lblShowPhone.text = strPhone;
    _lblCreditScore.text = [[NSString alloc] initWithFormat:@"信用分 %@ >",_user.CreditScore];
    _lblName.text = _user.Name;
    _lblSex.text = [[_user.Sex lowercaseString] isEqualToString:@"true"]?@"男":@"女";
    _lblIdentity.text = _user.IdentityName;
    _lblBirthday.text = _user.Birthday;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 1:{
            UpdateUserViewController *updateUserVC = (UpdateUserViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDUpdateUserVC"];
            updateUserVC.user = _user;
            updateUserVC.type = @"name";
            [self.navigationController pushViewController:updateUserVC animated:YES];
            break;
        }
        case 2:
            [self presentViewController:alertSex animated:YES completion:nil];
            break;
        case 3:
            [self presentViewController:alertBirthday animated:YES completion:nil];
            break;
        case 5:{
            UpdateUserViewController *updateUserVC = (UpdateUserViewController *)[storyboard instantiateViewControllerWithIdentifier:@"storyIDUpdateUserVC"];
            updateUserVC.user = _user;
            updateUserVC.type = @"phone";
            [self.navigationController pushViewController:updateUserVC animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)initDatePicker
{
    UIDatePicker *dpBirthday = [[UIDatePicker alloc] initWithFrame:CGRectMake(18, 15, screen.size.width*0.85, 167)];
    dpBirthday.datePickerMode = UIDatePickerModeDate;//时间模式的选择 有多种
    NSDate *date = [formatter dateFromString:self.lblBirthday.text];
    dpBirthday.date = date;
    //用自定义的UIAlertController选择ActionShee信息模式  并将中间的信息显示范围空出来 高度自由指定
    alertBirthday = [UIAlertController alertControllerWithTitle:nil message:@"\n\n\n\n\n\n\n\n\n" preferredStyle:UIAlertControllerStyleActionSheet];
    [alertBirthday.view addSubview:dpBirthday];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString* currentTime = [formatter stringFromDate:dpBirthday.date];
        self.lblBirthday.text = currentTime;
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
        _user.Sex = @"true";
        self.lblSex.text = @"男";
        [self.cellSex setSelected:NO animated:YES];
    }];
    UIAlertAction *womanAction = [UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _user.Sex = @"false";
        self.lblSex.text = @"女";
        [self.cellSex setSelected:NO animated:YES];
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
    _imgPhoto.image = [photos objectAtIndex:0];
}

- (IBAction)actionImgPhoto:(id)sender {
    [self presentViewController:alertPhoto animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
