//
//  PointinfoViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "PointinfoViewController.h"

@interface PointinfoViewController ()
{
    UITextField *_currentTextField;
    UITextView *_currentTextView;
}
@end

@implementation PointinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //获取设置当前方向
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    //设置横屏时的约束，默认为竖屏约束
    if (orientation==UIDeviceOrientationLandscapeLeft||orientation==UIDeviceOrientationLandscapeRight) {
        self.containerLeftCons.constant = 40;
        self.containerWidthCons.constant = -80;
        self.pointidWidthCons.constant = 180;
    }
    
    self.pointidTextF.delegate = self;
    self.earthidTextF.delegate = self;
    self.pointlocationTextF.delegate = self;
    self.pointlonTextF.delegate = self;
    self.pointlatTextF.delegate = self;
    self.pointnameTextF.delegate = self;
    self.pointtimeTextF.delegate = self;
    self.pointgroupTextF.delegate = self;
    self.pointintensityTextF.delegate = self;
    self.pointcontentTextV.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)dealloc
{
    //删除监听键盘通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        self.pointidWidthCons.constant = 180;
    }else{
        //将要旋转到竖屏时
        self.containerLeftCons.constant = 20;
        self.containerWidthCons.constant = -40;
        self.pointidWidthCons.constant = 90;
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

#pragma mark UITextViewDelegate方法
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _currentTextView = textView;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    _currentTextView = nil;
}

/**
 *  处理键盘遮挡文本
 */
-(void)keyBoardWillShow:(NSNotification *)notification
{
    //键盘高
    NSDictionary *keyboardDict = [notification userInfo];
    CGFloat keyboardHeight = [[keyboardDict objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size.height;
    //动画时间
    CGFloat duration = 0.5;
    
    //键盘顶部到屏幕顶部距离
    CGFloat keyboardTopToViewTop;
    //当前文本框在屏幕中的位置
    CGRect currentTextFieldFrame;
    CGRect currentTextViewFrame;
    //当前文本框底部到屏幕顶部距离
    CGFloat currentTextFieldBottom;
    CGFloat currentTextViewBottom;
    
    //如果当前控制器的根view是作为surveyPointDetailView的子控件且当前文本框是UITextField则执行下面代码
    if (self.surveyPointDetailView !=nil && _currentTextView ==nil) {
        keyboardTopToViewTop = self.surveyPointDetailView.height - keyboardHeight;
        currentTextFieldFrame = [self.surveyPointDetailView convertRect:_currentTextField.frame fromView:self.containerView];
        currentTextFieldBottom = CGRectGetMaxY(currentTextFieldFrame);
        
        //条件成立，说明键盘遮挡了文本框
        if (currentTextFieldBottom >= keyboardTopToViewTop) {
            self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0, currentTextFieldBottom - keyboardTopToViewTop+50, 0);
            //向上移动
            [UIView animateWithDuration:duration animations:^{
                self.rootScrollView.contentOffset = CGPointMake(0,currentTextFieldBottom - keyboardTopToViewTop+50);
            }];
        }
    }else if (self.surveyPointDetailView !=nil && _currentTextView !=nil){
        //如果当前控制器的根view是作为surveyPointDetailView的子控件且当前文本框是UITextView则执行下面代码
        keyboardTopToViewTop = self.surveyPointDetailView.height - keyboardHeight;
        currentTextViewFrame = [self.surveyPointDetailView convertRect:_currentTextView.frame fromView:self.containerView];
        currentTextViewBottom = CGRectGetMaxY(currentTextViewFrame);
        
        //条件成立，说明键盘遮挡了文本框
        if (currentTextViewBottom >= keyboardTopToViewTop) {
            self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0, currentTextViewBottom - keyboardTopToViewTop+50, 0);
            //向上移动
            //向上移动
            [UIView animateWithDuration:duration animations:^{
                self.rootScrollView.contentOffset = CGPointMake(0,currentTextViewBottom - keyboardTopToViewTop+50);
            }];
        }
    }
}

/**
 *  处理键盘遮挡文本
 */
-(void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat duration = 0.25;
    //将rootScrollView的contentInset和contentOffset复原
    if (self.surveyPointDetailView !=nil) {
        [UIView animateWithDuration:duration animations:^{
            self.rootScrollView.contentOffset = CGPointMake(0,0);
        }];
        self.rootScrollView.contentInset = UIEdgeInsetsZero;
    }
}

@end
