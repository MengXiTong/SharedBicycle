//
//  MQVerCodeImageView.h
//  SharedBicycle
//
//  Created by 俞健 on 2018/4/28.
//  Copyright © 2018年 俞健. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MQCodeImageBlock)(NSString *codeStr);
@interface MQVerCodeImageView : UIView

@property (nonatomic, strong) NSString *imageCodeStr;
@property (nonatomic, assign) BOOL isRotation;
@property (nonatomic, copy) MQCodeImageBlock bolck;

-(void)freshVerCode;

@end
