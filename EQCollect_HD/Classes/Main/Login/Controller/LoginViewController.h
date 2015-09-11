//
//  LoginViewController.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/8/27.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *loginBoxView;          //登录框的背景view
@property (weak, nonatomic) IBOutlet UIView *inputBgView;           //输入账号密码的背景view
@property (weak, nonatomic) IBOutlet UITextField *accountTextF;     //账号文本输入框
@property (weak, nonatomic) IBOutlet UITextField *passwdTextF;      //密码文本输入框
@property (weak, nonatomic) IBOutlet UIButton *loginNowBtn;         //登录按钮
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginBoxCenterYCons;

- (IBAction)forgetPasswd:(id)sender;
- (IBAction)loginNow:(id)sender;

@end
