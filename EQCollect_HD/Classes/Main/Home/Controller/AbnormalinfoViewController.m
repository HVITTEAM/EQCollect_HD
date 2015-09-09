//
//  AbnormalinfoViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "AbnormalinfoViewController.h"

@interface AbnormalinfoViewController ()
{
    UITextField *_currentTextField;
}
@end

@implementation AbnormalinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"宏观异常详情";
    
    //获取设置当前方向
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    //设置横屏时的约束，默认为竖屏约束
    if (orientation==UIDeviceOrientationLandscapeLeft||orientation==UIDeviceOrientationLandscapeRight) {
        self.containerLeftCons.constant = 40;
        self.containerWidthCons.constant = -80;
        self.abnormalidWidthCons.constant = 180;
    }
    
    self.abnormalidTextF.delegate = self;
    self.abnormaltimeTextF.delegate = self;
    self.informantTextF.delegate = self;
    self.abnormalintensityTextF.delegate = self;
    self.groundwaterTextF.delegate = self;
    self.abnormalhabitTextF.delegate = self;
    self.abnormalphenomenonTextF.delegate = self;
    self.otherTextF.delegate = self;
    self.implementationTextF.delegate= self;
    self.abnormalanalysisTextF.delegate = self;
    self.crediblyTextF.delegate = self;
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
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
    {
        //将要旋转到横屏时
        self.containerLeftCons.constant = 40;
        self.containerWidthCons.constant = -80;
        self.abnormalidWidthCons.constant = 180;
    }else{
        //将要旋转到竖屏时
        self.containerLeftCons.constant = 20;
        self.containerWidthCons.constant = -40;
        self.abnormalidWidthCons.constant = 90;
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
        self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0, -64+currentTextFieldBottom - keyboardTopToViewTop+50, 0);
        //向上移动
        [UIView animateWithDuration:duration delay:0 options:animationCurve animations:^{
            
            self.rootScrollView.contentOffset = CGPointMake(0,-64+currentTextFieldBottom - keyboardTopToViewTop+50);
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
        self.rootScrollView.contentOffset = CGPointMake(0,-64);
    } completion:nil];
}

@end
