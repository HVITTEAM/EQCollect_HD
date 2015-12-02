//
//  LoginViewController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/8/27.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "LoginViewController.h"
#import "LocationHelper.h"

@interface LoginViewController ()
{
    UITextField *_currentTextField;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginBoxView.layer.cornerRadius = 10.0f;
    self.loginBoxView.layer.masksToBounds = YES;
    self.loginBoxView.clipsToBounds = YES;
    
    self.inputBgView.layer.cornerRadius = 5.0f;
    self.inputBgView.layer.masksToBounds = YES;
    
    self.loginNowBtn.layer.cornerRadius = 5.0f;
    self.loginNowBtn.layer.masksToBounds = YES;
    
    self.accountTextF.delegate = self;
    self.passwdTextF.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //删除监听键盘通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark UITextFieldDelegate方法
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _currentTextField = nil;
}

/**
 *  处理键盘遮挡文本
 */
-(void)keyBoardWillShow:(NSNotification *)notification
{
    //获取键盘动画曲线和持续时间和键盘高
    NSDictionary *keyboardDict = [notification userInfo];
    //CGFloat keyboardHeight = [[keyboardDict objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size.height;
    CGRect keybaordFrame = [[keyboardDict objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    CGFloat keyboardHeight;
    if (IOS_VERSION < 8.0) {
        keyboardHeight = keybaordFrame.size.width;
    }else{
        keyboardHeight = keybaordFrame.size.height;
    }
    NSInteger animationCurve = [[keyboardDict objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat duration = [[keyboardDict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //键盘顶部到屏幕顶部距离
    CGFloat keyboardTopToViewTop = self.view.bounds.size.height - keyboardHeight;
    //当前文本框底部到屏幕顶部距离
    CGRect currentTextFieldFrame = [self.view convertRect:_currentTextField.frame fromView:self.inputBgView];
    CGFloat currentTextFieldBottom = CGRectGetMaxY(currentTextFieldFrame);
    //条件成立，说明键盘遮挡了文本框
    if (currentTextFieldBottom >= keyboardTopToViewTop-60) {
        //向上移动
        self.loginBoxCenterYCons.constant += currentTextFieldBottom - keyboardTopToViewTop+60;
        [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
            //更新约束
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

/**
 *  处理键盘遮挡文本
 */
-(void)keyboardWillHide:(NSNotification *)notification
{
    //获取键盘动画曲线和持续时间
    NSDictionary *keyboardDict = [notification userInfo];
    NSInteger animationCurve = [[keyboardDict objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat duration = [[keyboardDict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //复原约束
    self.loginBoxCenterYCons.constant = 0;
    [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
        //更新约束
        [self.view layoutIfNeeded];
    } completion:nil];
}

/**
 *  忘记密码
 */
- (IBAction)forgetPasswd:(id)sender {
    NSLog(@"忘记密码");
}

/**
 *  登录
 */
- (IBAction)loginNow:(id)sender
{
    NSString *account = self.accountTextF.text;
    NSString *passwd = self.passwdTextF.text;
    if (account!=nil && account.length>0 && passwd!=nil && passwd.length>0)
    {
        MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [CommonRemoteHelper RemoteWithUrl:URL_Login parameters: @{@"loginname" : account,
                                                                  @"pwd" : passwd,@"from":@"app"}
                                     type:CommonRemoteTypePost success:^(NSDictionary *dict, id responseObject) {
                                        Boolean loginResult = [dict[@"success"] boolValue];
                                        NSLog(@"login-----dict%@      responseobject%@",dict,responseObject);
                                         if (loginResult) {
                                             UserModel *usermd = [UserModel objectWithKeyValues:dict];
                                             [ArchiverCacheHelper saveObjectToLoacl:usermd key:User_Archiver_Key filePath:User_Archiver_Path];
                                             [HUD removeFromSuperview];
                                             [HMControllerTool setRootViewController];
                                         }else{
                                             [HUD removeFromSuperview];
                                              [NoticeHelper AlertShow:@"登陆失败！请重试！" view:self.view];
                                         }
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"发生错误");
                                         [HUD removeFromSuperview];
                                         [NoticeHelper AlertShow:@"网络联接异常" view:self.view];
                                     }];
    }
    else
    {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:@"帐号或密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertV show];
    }
  // [HMControllerTool setRootViewController];
}

-(void)dealloc
{
    NSLog(@"LoginViewController释放了吗");
}
@end
