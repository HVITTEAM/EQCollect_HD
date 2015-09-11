//
//  damageinfoViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#define kNormalNavHeight 64
#define kAddNavheight 44
#import "DamageinfoViewController.h"

@interface DamageinfoViewController ()
{
    UITextField *_currentTextField;
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
}
@end

@implementation DamageinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"房屋震害";
    
    //默认有状态栏，高度为64
    _navHeight = kNormalNavHeight;
    if (self.isAdd ) {
        //设置导航栏按钮
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(add)];
        self.navigationItem.leftBarButtonItem = leftItem;
        self.navigationItem.rightBarButtonItem = rigthItem;
        
        //当为新增时没有状态栏，高度为44
        _navHeight = kAddNavheight;
    }
    
    //获取设备当前方向
    UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
    //将UIDeviceOrientation类型转为UIInterfaceOrientation
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)devOrientation;
    //根据屏幕方向设置视图的约束
    [self rotationToInterfaceOrientation:interfaceOrientation];
    
    self.textInputViews = @[
                            self.damageidTextF,
                            self.damagetimeTextF,
                            self.zrcorxqTextF,
                            self.dworzhTextF,
                            self.fortificationintensityTextF,
                            self.damageintensityTextF,
                            self.damagesituationTextF,
                            self.damageindexTextF,
                            self.damageaddressTextF
                            ];
    for (int i = 0;i<self.textInputViews.count;i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }
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

//处理屏幕旋转
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self rotationToInterfaceOrientation:interfaceOrientation];
}

/**
 *  旋转屏幕时更改约束
 *
 *  @param interfaceOrientation 要旋转的方向
 */
-(void)rotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{

    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)&& !self.isAdd)
    {
        //设备为横屏且不是新增界面，设置为横屏约束
        self.containerTopCons.constant = 30+_navHeight;
        self.containerLeftCons.constant = 40;
        self.containerWidthCons.constant = -80;
        self.damageidWidthCons.constant = 180;
    }else{
        //设备为竖屏或新增界面，设置为竖屏约束
        self.containerTopCons.constant = 20+_navHeight;
        self.containerLeftCons.constant = 20;
        self.containerWidthCons.constant = -40;
        self.damageidWidthCons.constant = 100;
    }
    //更新约束
    [self.view updateConstraintsIfNeeded];
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext) {
        //根据tag获取下一个文本框
        UITextField *textF =(UITextField *)[self.containerView viewWithTag:textField.tag+1];
        [textF becomeFirstResponder];
    }
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
    }
    return YES;
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
    CGRect currentTextFieldFrame = [self.view convertRect:_currentTextField.frame fromView:self.containerView];
    CGFloat currentTextFieldBottom = CGRectGetMaxY(currentTextFieldFrame);
    
    //条件成立，说明键盘遮挡了文本框
    if (currentTextFieldBottom >= keyboardTopToViewTop) {
        
        self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0, currentTextFieldBottom - keyboardTopToViewTop+60, 0);
        //向上移动
        [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
            
            self.rootScrollView.contentOffset = CGPointMake(0,currentTextFieldBottom - keyboardTopToViewTop+60);
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
    
    //将rootScrollView的contentInset和contentOffset复原
    self.rootScrollView.contentInset = UIEdgeInsetsZero;
    [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
        self.rootScrollView.contentOffset = CGPointMake(0,0);
    } completion:nil];
}

/**
 *  新增房屋震害信息
 */
-(void)add
{
    NSLog(@"新增");
    [self dismissViewControllerAnimated:self completion:nil];
}

-(void)back
{
    [self dismissViewControllerAnimated:self completion:nil];
}

@end
