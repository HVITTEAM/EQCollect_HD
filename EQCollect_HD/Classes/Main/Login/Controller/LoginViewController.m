//
//  LoginViewController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/8/27.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "LoginViewController.h"
#import "MasterViewController.h"
#import "DetailViewController.h"

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
    CGFloat keyboardHeight = [[keyboardDict objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size.height;
    NSInteger animationCurve = [[keyboardDict objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGFloat duration = [[keyboardDict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //键盘顶部到屏幕顶部距离
    CGFloat keyboardTopToViewTop = self.view.height - keyboardHeight;
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
- (IBAction)loginNow:(id)sender {
    
    NSString *account = self.accountTextF.text;
    NSString *passwd = self.passwdTextF.text;
    if (account!=nil && account.length>0 && passwd!=nil && passwd.length>0) {
        
        [CommonRemoteHelper RemoteWithUrl:URL_Login parameters: @{@"loginname" : account,
                                                                  @"pwd" : passwd}
                                     type:CommonRemoteTypePost success:^(NSDictionary *dict, id responseObject) {
                                         
                                         MasterViewController *masterView = [[MasterViewController alloc] init];
                                         UINavigationController *masterNav =  [[UINavigationController alloc] initWithRootViewController:masterView];
                                         //创建用户数据模型
                                         UserModel *usermd = [[UserModel alloc] initWithNSDictionary:dict];
                                         masterView.usermd = usermd;
                                         
                                         DetailViewController *detailView = [[DetailViewController alloc] init];
                                         UINavigationController *detailNav =  [[UINavigationController alloc] initWithRootViewController:detailView];
                                         
                                         // 设置UISplitViewController的代理
                                         UISplitViewController *split = [[UISplitViewController alloc] init];
                                         split.viewControllers = @[masterNav,detailNav];
                                         split.delegate = detailNav.viewControllers[0];
                                         
                                         UIWindow *kWindow = [[UIApplication sharedApplication] keyWindow];
                                         kWindow.rootViewController = split;
                                         
                                         
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"发生错误！%@",error);
                                     }];

    }else{
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:@"帐号或密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertV show];
    }
    
}
@end
