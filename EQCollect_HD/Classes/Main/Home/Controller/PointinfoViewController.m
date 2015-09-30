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
    
}
@end

@implementation PointinfoViewController
{
    CGFloat _navHeight;       // 导航栏与状态栏总的高度
    
    NSUInteger _currentInputViewTag;  //当前文本框的tag
    
    NSNotification *_currentKeyboardNotification;   //保存键盘通知对象，键盘隐藏时为nil
    
    NSInteger _lastDistance;                  //键盘遮挡文本时前一次向上移动的距离
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initPointinfoVC];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showPointinfoData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  初始化调查点信息控制器
 */
-(void)initPointinfoVC
{
    //默认情况下ScrollView中的内容不会被导航栏遮挡
    _navHeight = 0;
    if (self.actionType == kActionTypeAdd ) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(addPointinfo)];
        self.navigationItem.rightBarButtonItem = rightItem;
        
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
    for (int i = 0;i < self.textInputViews.count-1; i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }
    //pointcontentTextV类型是UITextView单独处理
    self.pointcontentTextV.delegate = self;
    self.pointcontentTextV.tag = 1000 + self.textInputViews.count-1;
}

-(void)showPointinfoData
{
    if (self.actionType == kActionTypeShow || self.actionType == kactionTypeEdit)
    {
        self.pointidTextF.text = self.pointinfo.pointid;
        self.earthidTextF.text = self.pointinfo.earthid;
        self.pointlocationTextF.text = self.pointinfo.pointlocation;
        self.pointlonTextF.text = self.pointinfo.pointlon;
        self.pointlatTextF.text = self.pointinfo.pointlat;
        self.pointnameTextF.text = self.pointinfo.pointname;
        self.pointtimeTextF.text = self.pointinfo.pointtime;
        self.pointgroupTextF.text = self.pointinfo.pointgroup;
        self.pointintensityTextF.text = self.pointinfo.pointintensity;
        self.pointcontentTextV.text = self.pointinfo.pointcontent;
    }else
    {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        self.pointtimeTextF.text = [formatter stringFromDate:date];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
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
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)&&self.actionType == kActionTypeShow)
    {
        //设备为横屏且不是新增界面，设置为横屏约束
        self.pointidWidthCons.constant = 180;
    }else{
        //设备为竖屏或新增界面，设置为竖屏约束
        self.pointidWidthCons.constant = 100;
    }
    self.pointidTopCons.constant = 20+_navHeight;
    //更新约束
    [self.view updateConstraintsIfNeeded];
}

#pragma mark UITextFieldDelegate方法
//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_currentKeyboardNotification !=nil) {
        [self keyboardWillShow:_currentKeyboardNotification];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext) {
        _currentInputViewTag +=1;
        //根据tag获取下一个文本框
        UITextField *textF =(UITextField *)[self.view viewWithTag:_currentInputViewTag];
        [textF becomeFirstResponder];
    }
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL canEdit;
    _currentInputViewTag = textField.tag;
    
    if (self.actionType == kActionTypeAdd || self.actionType == kactionTypeEdit) {
        switch (textField.tag) {
            case 1003:
                canEdit = NO;
                break;
            default:
                canEdit = YES;
                break;
        }
    }else canEdit = NO;
    
    return canEdit;
}


#pragma mark UITextViewDelegate方法
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _currentInputViewTag = textView.tag;
    if (_currentKeyboardNotification !=nil) {
        [self keyboardWillShow:_currentKeyboardNotification];
    }
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textViewDidEndEditing:(UITextView *)textView
{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.actionType == kActionTypeAdd || self.actionType == kactionTypeEdit) {
        return YES;
    }else return NO;
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addPointinfo
{
    //NSString *pointid = self.pointidTextF.text;
    NSString *earthid = self.earthidTextF.text;
    NSString *pointlocation = self.pointlocationTextF.text;
    NSString *pointlon = self.pointlonTextF.text;
    NSString *pointlat = self.pointlatTextF.text;
    NSString *pointname = self.pointnameTextF.text;
    NSString *pointtime = self.pointtimeTextF.text;
    NSString *pointgroup = self.pointgroupTextF.text;
    NSString *pointperson1 = @"person1";
    NSString *pointperson2 = @"person2";
    NSString *pointintensity = self.pointintensityTextF.text;
    NSString *pointcontent = self.pointcontentTextV.text;
    NSString *upload = @"0";
    
    
    //判断文本输入框是否为空，如果为空则提示并返回
    for (int i=0; i<self.textInputViews.count; i++) {
        if (i!=self.textInputViews.count-1) {
            UITextField *textF = (UITextField *)self.textInputViews[i];
            if (textF.text ==nil || textF.text.length <=0) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"所填项目不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return;
            }
        }else{
            UITextView *textV = (UITextView *)self.textInputViews[i];
            if (textV.text ==nil || textV.text.length <=0) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"数据不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return;
            }
        }
    }
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
//                          pointid,@"pointid",
                          earthid,@"earthid",
                          pointlocation,@"pointlocation",
                          pointlon, @"pointlon",
                          pointlat, @"pointlat",
                          pointname,@"pointname",
                          pointtime,@"pointtime",
                          pointgroup,@"pointgroup",
                          pointperson1,@"pointperson1",
                          pointperson2,@"pointperson2",
                          pointintensity,@"pointintensity",
                          pointcontent,@"pointcontent",
                          upload,@"upload",nil];
    
    BOOL result = [[PointinfoTableHelper sharedInstance] insertDataWith:dict];
    if (!result) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错,请确定编号唯一" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{
        self.pointidTextF.text = nil;
        self.earthidTextF.text = nil;
        self.pointlocationTextF.text = nil;
        self.pointlonTextF.text = nil;
        self.pointlatTextF.text = nil;
        self.pointnameTextF.text = nil;
        self.pointtimeTextF.text = nil;
        self.pointgroupTextF.text = nil;
        self.pointintensityTextF.text = nil;
        self.pointcontentTextV.text = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddPointinfoSucceedNotification object:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


/**
 *  键盘处理方法，键盘将出现时调用
 */
-(void)keyboardWillShow:(NSNotification *)notification
{
    _currentKeyboardNotification = notification;
    UIWindow *keyWin = [[UIApplication sharedApplication] keyWindow];
    
    //获取键盘属性字典
    NSDictionary *keyboardDict = [notification userInfo];
    //获取键盘y值
    CGRect keyboardFrame = [[keyboardDict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = keyWin.frame.size.height - keyboardFrame.size.height;
    //获取键盘动画时间
    CGFloat duration = [[keyboardDict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //获取动画曲线
    NSInteger curve = [[keyboardDict objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    //获取当前文本框在window中的最大Y值
    UIView *currentInputView = [self.view viewWithTag:_currentInputViewTag];
    CGRect frameInWindow = [keyWin convertRect:currentInputView.frame fromView:self.containerView];
    CGFloat currentInputViewMaxY = CGRectGetMaxY(frameInWindow)+_lastDistance;  //加_lastDistance消除偏移
    
    //当键盘被遮挡时view上移
    if (currentInputViewMaxY > keyboardY-60) {
        self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0, currentInputViewMaxY - keyboardY+60, 0);
        [UIView animateKeyframesWithDuration:duration delay:0 options:curve animations:^{
            self.rootScrollView.contentOffset = CGPointMake(0, currentInputViewMaxY - keyboardY+60);
        } completion:nil];
        //将向上移距离赋值给_lastDistance
        _lastDistance = currentInputViewMaxY - keyboardY+60;
    }
}

/**
 *  键盘处理方法，键盘将隐藏时调用
 */
-(void)keyboardWillHide:(NSNotification *)notification
{
    //获取键盘属性字典
    NSDictionary *keyboardDict = [notification userInfo];
    //获取键盘动画时间
    CGFloat duration = [[keyboardDict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //获取动画曲线
    NSInteger curve = [[keyboardDict objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    //复原rootScrollView属性
    [UIView animateKeyframesWithDuration:duration delay:0 options:curve animations:^{
        self.rootScrollView.contentOffset = CGPointMake(0, 0);
    } completion:nil];
    self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _currentKeyboardNotification = nil;
    _lastDistance = 0;
    
}

-(void)updatePointinfo
{
    NSLog(@"更新数据");
    
    NSString *pointid = self.pointinfo.pointid;
    NSString *earthid = self.earthidTextF.text;
    NSString *pointlocation = self.pointlocationTextF.text;
    NSString *pointlon = self.pointlonTextF.text;
    NSString *pointlat = self.pointlatTextF.text;
    NSString *pointname = self.pointnameTextF.text;
    NSString *pointtime = self.pointtimeTextF.text;
    NSString *pointgroup = self.pointgroupTextF.text;
    NSString *pointperson1 = @"person1";
    NSString *pointperson2 = @"person2";
    NSString *pointintensity = self.pointintensityTextF.text;
    NSString *pointcontent = self.pointcontentTextV.text;
    NSString *upload = @"0";
    
    
    //判断文本输入框是否为空，如果为空则提示并返回
    for (int i=0; i<self.textInputViews.count; i++) {
        if (i!=self.textInputViews.count-1) {
            UITextField *textF = (UITextField *)self.textInputViews[i];
            if (textF.text ==nil || textF.text.length <=0) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"所填项目不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return;
            }
        }else{
            UITextView *textV = (UITextView *)self.textInputViews[i];
            if (textV.text ==nil || textV.text.length <=0) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"数据不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return;
            }
        }
    }
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          pointid,@"pointid",
                          earthid,@"earthid",
                          pointlocation,@"pointlocation",
                          pointlon, @"pointlon",
                          pointlat, @"pointlat",
                          pointname,@"pointname",
                          pointtime,@"pointtime",
                          pointgroup,@"pointgroup",
                          pointperson1,@"pointperson1",
                          pointperson2,@"pointperson2",
                          pointintensity,@"pointintensity",
                          pointcontent,@"pointcontent",
                          upload,@"upload",nil];
    
    BOOL result = [[PointinfoTableHelper sharedInstance]updateDataWith:dict];
    if (!result) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错,请确定编号唯一" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{
        [self.view endEditing:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddPointinfoSucceedNotification object:nil];
    }
    [self dismissViewControllerAnimated:YES completion:nil];

    
}

@end

