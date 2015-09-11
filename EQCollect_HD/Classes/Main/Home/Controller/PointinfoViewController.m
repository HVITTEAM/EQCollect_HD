//
//  PointinfoViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
#define kNormalNavHeight 64
#define kAddNavheight 44
#import "PointinfoViewController.h"

@interface PointinfoViewController ()
{
    UITextField *_currentTextField;
    UITextView *_currentTextView;
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
}
@end

@implementation PointinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //默认情况下ScrollView中的内容不会被导航栏遮挡
    _navHeight = 0;
    if (self.isAdd ) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        
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
                            self.pointidTextF,
                            self.pointlocationTextF,
                            self.pointnameTextF,
                            self.pointtimeTextF,
                            self.earthidTextF,
                            self.pointlonTextF,
                            self.pointlatTextF,
                            self.pointgroupTextF,
                            self.pointintensityTextF,
                            self.pointcontentTextV
                            ];
    for (int i = 0;i<self.textInputViews.count-1;i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }
    //pointcontentTextV类型是UITextView单独处理
    self.pointcontentTextV.delegate = self;
    self.pointcontentTextV.tag = 1000+self.textInputViews.count-1;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardDidHideNotification object:nil];
}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    //删除监听键盘通知
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

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

    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)&&!self.isAdd)
    {
        //设备为横屏且不是新增界面，设置为横屏约束
        self.containerTopCons.constant = 30+_navHeight;
        self.containerLeftCons.constant = 40;
        self.containerWidthCons.constant = -80;
        self.pointidWidthCons.constant = 180;
    }else{
        //设备为竖屏或新增界面，设置为竖屏约束
        self.containerTopCons.constant = 20+_navHeight;
        self.containerLeftCons.constant = 20;
        self.containerWidthCons.constant = -40;
        self.pointidWidthCons.constant = 100;
    }
    //更新约束
    [self.view updateConstraintsIfNeeded];
}

#pragma mark UITextFieldDelegate方法
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _currentTextView = nil;
    _currentTextField = textField;
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

#pragma mark UITextViewDelegate方法
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _currentTextField = nil;
    _currentTextView = textView;
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
    if (self.parentView !=nil && _currentTextView ==nil) {
        keyboardTopToViewTop = self.parentView.height - keyboardHeight;
        currentTextFieldFrame = [self.parentView convertRect:_currentTextField.frame fromView:self.containerView];
        currentTextFieldBottom = CGRectGetMaxY(currentTextFieldFrame);
        
        //条件成立，说明键盘遮挡了文本框
        if (currentTextFieldBottom >= keyboardTopToViewTop) {
            self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0, currentTextFieldBottom - keyboardTopToViewTop+60, 0);
            //向上移动
            [UIView animateWithDuration:duration animations:^{
                self.rootScrollView.contentOffset = CGPointMake(0,currentTextFieldBottom - keyboardTopToViewTop+60);
            }];
        }
    }else if (self.parentView !=nil && _currentTextView !=nil){
        //如果当前控制器的根view是作为surveyPointDetailView的子控件且当前文本框是UITextView则执行下面代码
        keyboardTopToViewTop = self.parentView.height - keyboardHeight;
        currentTextViewFrame = [self.parentView convertRect:_currentTextView.frame fromView:self.containerView];
        currentTextViewBottom = CGRectGetMaxY(currentTextViewFrame);
        
        //条件成立，说明键盘遮挡了文本框
        if (currentTextViewBottom >= keyboardTopToViewTop) {
            self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0, currentTextViewBottom - keyboardTopToViewTop+60, 0);
            //向上移动
            //向上移动
            [UIView animateWithDuration:duration animations:^{
                self.rootScrollView.contentOffset = CGPointMake(0,currentTextViewBottom - keyboardTopToViewTop+60);
            }];
        }
    }else if (self.parentView == nil && _currentTextView ==nil){
        //当前文本框是UITextField则执行下面代码
        keyboardTopToViewTop = self.view.height - keyboardHeight;
        currentTextFieldFrame = [self.view convertRect:_currentTextField.frame fromView:self.containerView];
        currentTextFieldBottom = CGRectGetMaxY(currentTextFieldFrame);
        
         //条件成立，说明键盘遮挡了文本框
        if (currentTextFieldBottom >= keyboardTopToViewTop) {
            self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0,currentTextFieldBottom - keyboardTopToViewTop+60, 0);
            //向上移动
            [UIView animateWithDuration:duration animations:^{
                self.rootScrollView.contentOffset = CGPointMake(0,currentTextFieldBottom - keyboardTopToViewTop+60);
            }];
        }
    }else{
        //当前文本框是UITextView则执行下面代码
        keyboardTopToViewTop = self.view.height - keyboardHeight;
        currentTextViewFrame = [self.view convertRect:_currentTextView.frame fromView:self.containerView];
        currentTextViewBottom = CGRectGetMaxY(currentTextViewFrame);
        
        //条件成立，说明键盘遮挡了文本框
        if (currentTextViewBottom >= keyboardTopToViewTop) {
            self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0,currentTextViewBottom - keyboardTopToViewTop+60, 0);
            //向上移动
            [UIView animateWithDuration:duration animations:^{
                self.rootScrollView.contentOffset = CGPointMake(0,currentTextViewBottom - keyboardTopToViewTop+60);
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
    [UIView animateWithDuration:duration animations:^{
            self.rootScrollView.contentOffset = CGPointMake(0,0);
    }];
    self.rootScrollView.contentInset = UIEdgeInsetsZero;
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
