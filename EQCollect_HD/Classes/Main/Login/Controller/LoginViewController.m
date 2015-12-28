//
//  LoginViewController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/8/27.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "LoginViewController.h"
#import "LocationHelper.h"
#import "CurrentUser.h"

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *loginBoxView;          //登录框的背景view
@property (weak, nonatomic) IBOutlet UIView *inputBgView;           //输入账号密码的背景view
@property (weak, nonatomic) IBOutlet UITextField *accountTextF;     //账号文本输入框
@property (weak, nonatomic) IBOutlet UITextField *passwdTextF;      //密码文本输入框
@property (weak, nonatomic) IBOutlet UIButton *loginNowBtn;         //登录按钮

@property(strong,nonatomic)UITextField *currentTextField;          //当前正在编辑的输入框

- (IBAction)loginNow:(id)sender;

@end

@implementation LoginViewController

#pragma mark -- 生命周期方法 --

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubView];
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

#pragma mark -- 初始化方法 --
-(void)initSubView
{
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

#pragma mark -- 协议方法 --
#pragma mark UITextFieldDelegate方法
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.currentTextField = nil;
}

#pragma mark -- 事件方法 --
#pragma mark 键盘事件相关方法
/**
 *  处理键盘遮挡文本
 */
-(void)keyBoardWillShow:(NSNotification *)notification
{
    //获取键盘动画曲线和持续时间和键盘高
    NSDictionary *keyboardDict = [notification userInfo];
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
    CGRect currentTextFieldFrame = [self.view convertRect:self.currentTextField.frame fromView:self.inputBgView];
    CGFloat currentTextFieldBottom = CGRectGetMaxY(currentTextFieldFrame);
    //条件成立，说明键盘遮挡了文本框
    if (currentTextFieldBottom + 60 >= keyboardTopToViewTop) {
        [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
            self.view.bounds = CGRectMake(0, currentTextFieldBottom + 60 - keyboardTopToViewTop,
                                                 self.view.bounds.size.width, self.view.bounds.size.height);
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
    
    [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
        self.view.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    } completion:nil];
}

#pragma mark 登录方法
- (IBAction)loginNow:(id)sender
{
    NSString *account = self.accountTextF.text;
    NSString *passwd = self.passwdTextF.text;
    if (account == nil && account.length <= 0 && passwd == nil && passwd.length <= 0)
    {
        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:nil message:@"帐号、密码不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertV show];
        return;
    }
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSDictionary *params = @{
                             @"loginname" : account,
                             @"pwd" : passwd,
                             @"from":@"app"
                             };
    [CommonRemoteHelper RemoteWithUrl:URL_Login parameters:params type:CommonRemoteTypePost success:^(id responseObject) {
        [HUD removeFromSuperview];
        [self handleResponse:responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HUD removeFromSuperview];
        [NoticeHelper AlertShow:@"网络联接异常" view:self.view];
    }];
    
   //[HMControllerTool setRootViewController];
}

/**
 *  处理登录结果
 */
-(void)handleResponse:(id)responseObject
{
    Boolean loginResult = [responseObject[@"success"] boolValue];
    if (loginResult) {
        //保存登录用户信息
       CurrentUser *userTemp = [CurrentUser objectWithKeyValues:(NSDictionary *)responseObject];
       CurrentUser *curtuser = [CurrentUser shareInstance];
        curtuser.userid    = userTemp.userid;
        curtuser.jobid     = userTemp.jobid;
        curtuser.groupid   = userTemp.groupid;
        curtuser.roleid    = userTemp.roleid;
        curtuser.userccount = userTemp.userccount;
        curtuser.username  = userTemp.username;
        curtuser.userpwd   = userTemp.userpwd;
        curtuser.useraddress = userTemp.useraddress;
        curtuser.userstatus = userTemp.userstatus;
        curtuser.userlon   = userTemp.userlon;
        curtuser.userlat   = userTemp.userlat;
        curtuser.usertel   = userTemp.usertel;
        curtuser.jobname   = userTemp.jobname;
        curtuser.groupname = userTemp.groupname;
        curtuser.pointgroup = userTemp.pointgroup;
        curtuser.pointperson = userTemp.pointperson;
        curtuser.success   =  userTemp.success;
        
        //跳转到主界面
        [HMControllerTool setRootViewController];
        
    }else{
        [NoticeHelper AlertShow:@"登陆失败！请重试！" view:self.view];
    }
}

-(void)dealloc
{
    NSLog(@"LoginViewController释放了吗");
}
@end
