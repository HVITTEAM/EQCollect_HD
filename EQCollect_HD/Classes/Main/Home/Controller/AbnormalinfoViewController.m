//
//  AbnormalinfoViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
#define kNormalNavHeight 64
#define kAddNavheight 44
#import "AbnormalinfoViewController.h"

@interface AbnormalinfoViewController ()
{
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
    CGFloat keyBoardHeight;         //键盘高度
    NSUInteger _currentInputViewTag;  //当前文本框的tag
}
@end

@implementation AbnormalinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAbnormalinfoVC];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showAbnormalinfoData];
}

/**
 *  初始化宏观异常信息控制器
 */
-(void)initAbnormalinfoVC
{
    self.navigationItem.title = @"宏观异常";
    
    keyBoardHeight = 352;
    //默认有状态栏，高度为64
    _navHeight = kNormalNavHeight;
    //禁用交互
    [self.view setUserInteractionEnabled:NO];
    if (self.isAdd ) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(addAbnormalinfo)];
        self.navigationItem.leftBarButtonItem = leftItem;
        self.navigationItem.rightBarButtonItem = rigthItem;
        
        //当为新增时没有状态栏，高度为44
        _navHeight = kAddNavheight;
        //启用交互
        [self.view setUserInteractionEnabled:YES];
    }
    //获取设备当前方向
    UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
    //将UIDeviceOrientation类型转为UIInterfaceOrientation
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)devOrientation;
    //根据屏幕方向设置视图的约束
    [self rotationToInterfaceOrientation:interfaceOrientation];
    
    self.textInputViews = @[
                            self.abnormalidTextF,
                            self.abnormaltimeTextF,
                            self.informantTextF,
                            self.abnormalintensityTextF,
                            self.groundwaterTextF,
                            self.abnormalhabitTextF,
                            self.abnormalphenomenonTextF,
                            self.otherTextF,
                            self.implementationTextF,
                            self.abnormalanalysisTextF,
                            self.crediblyTextF
                            ];
    for (int i = 0;i<self.textInputViews.count;i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }
    
    self.intensityItems = @[@"强",@"中等",@"弱"];
    self.groundwaterItems = @[@"地下水1",@"地下水2",@"地下水3",@"地下水4"];
    self.habitItems = @[@"习性1",@"习性2",@"习性3",@"习性4"];
    self.phenomenonItems = @[@"物化1",@"物化2",@"物化3",@"物化4",@"物化5"];
    
}

-(void)showAbnormalinfoData
{
    if (!self.isAdd) {
        self.abnormalidTextF.text = self.abnormalinfo.abnormalid;
        self.abnormaltimeTextF.text = self.abnormalinfo.abnormaltime;
        self.informantTextF.text = self.abnormalinfo.informant;
        self.abnormalintensityTextF.text = self.abnormalinfo.abnormalintensity;
        self.groundwaterTextF.text = self.abnormalinfo.groundwater;
        self.abnormalhabitTextF.text = self.abnormalinfo.abnormalhabit;
        self.abnormalphenomenonTextF.text = self.abnormalinfo.abnormalphenomenon;
        self.otherTextF.text = self.abnormalinfo.other;
        self.implementationTextF.text = self.abnormalinfo.implementation;
        self.abnormalanalysisTextF.text = self.abnormalinfo.abnormalanalysis;
        self.crediblyTextF.text = self.abnormalinfo.credibly;
    }
}

//处理屏幕旋转
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    switch (interfaceOrientation)
    {
        case UIInterfaceOrientationPortrait:
            keyBoardHeight = 264 - 100;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            keyBoardHeight = 264 - 100;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            keyBoardHeight = 352;
            break;
        case UIInterfaceOrientationLandscapeRight:
            keyBoardHeight = 352;
            break;
        default:
            break;
    }
    [self rotationToInterfaceOrientation:interfaceOrientation];
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
        self.abnormalidWidthCons.constant = 180;
    }else{
        //设备为竖屏或新增界面，设置为竖屏约束
        self.abnormalidWidthCons.constant = 100;
    }
    self.abnormalidTopCons.constant = 20+_navHeight;
    //更新约束
    [self.view updateConstraintsIfNeeded];
}

#pragma mark UITextFieldDelegate方法
//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;
    int offset = CGRectGetMaxY(frame) - (self.view.frame.size.height - keyBoardHeight + 30);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.bounds = CGRectMake(0.0f, offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

//输入框编辑完成以后，将视图恢复到原始状态
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.bounds =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext) {
        //根据tag获取下一个文本框
        UITextField *textF =(UITextField *)[self.view viewWithTag:textField.tag+1];
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
    
    //根据文本框的tag来确定哪些允许手动输入，哪些需要弹出框来选择
    switch (_currentInputViewTag) {
        case 1003:
            canEdit = NO;
            [self showActionSheetWithTextField:textField items:self.intensityItems];
            break;
        case 1004:
            canEdit = NO;
            [self showActionSheetWithTextField:textField items:self.groundwaterItems];
            break;
        case 1005:
            canEdit = NO;
            [self showActionSheetWithTextField:textField items:self.habitItems];
            break;
        case 1006:
            canEdit = NO;
            [self showActionSheetWithTextField:textField items:self.phenomenonItems];
            break;
        default:
            canEdit = YES;
            break;
    }
    return canEdit;
}

-(void)addAbnormalinfo
{
    NSString *abnormalid = self.abnormalidTextF.text;
    NSString *abnormaltime = self.abnormaltimeTextF.text;
    NSString *informant = self.informantTextF.text;
    NSString *abnormalintensity = self.abnormalintensityTextF.text;
    NSString *groundwater = self.groundwaterTextF.text;
    NSString *abnormalhabit = self.abnormalhabitTextF.text;
    NSString *abnormalphenomenon = self.abnormalphenomenonTextF.text;
    NSString *other = self.otherTextF.text;
    NSString *implementation = self.implementationTextF.text;
    NSString *abnormalanalysis = self.abnormalanalysisTextF.text;
    NSString *credibly = self.crediblyTextF.text;
    
    //判断文本输入框是否为空，如果为空则提示并返回
    for (int i=0; i<self.textInputViews.count; i++) {
        UITextField *textF = (UITextField *)self.textInputViews[i];
        if (textF.text ==nil || textF.text.length <=0) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"所填项目不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return;
        }
    }
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          abnormalid,@"abnormalid",
                          abnormaltime,@"abnormaltime",
                          informant,@"informant",
                          abnormalintensity, @"abnormalintensity",
                          groundwater, @"groundwater",
                          abnormalhabit,@"abnormalhabit",
                          abnormalphenomenon,@"abnormalphenomenon",
                          other,@"other",
                          implementation,@"implementation",
                          abnormalanalysis,@"abnormalanalysis",
                          credibly,@"credibly",
                          self.pointid,@"pointid",
                          nil];
    
    BOOL result = [[AbnormalinfoTableHelper sharedInstance] insertDataWith:dict];
    if (!result) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }

    [self dismissViewControllerAnimated:self completion:nil];
}

-(void)back
{
    [self dismissViewControllerAnimated:self completion:nil];
}

/**
 *  使用UIActionSheet向文本框输入内容
 *
 *  @param textField 需要输入内容的文本框
 *  @param items     选项数组
 */
-(void)showActionSheetWithTextField:(UITextField *)textField items:(NSArray *)items
{
    //创建UIActionSheet并设置标题
    NSString *titleStr = [NSString stringWithFormat:@"%@选项",textField.placeholder];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:titleStr delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    //添加ActionSheet控件上的按钮
    for (NSString *buttonTitle in items) {
        [actionSheet addButtonWithTitle:buttonTitle];
    }
    //显示ActionSheet控件
    [actionSheet showInView:self.view];
}

#pragma mark UIActionSheetDelegate方法
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *inputView = (UITextField *)[self.view viewWithTag:_currentInputViewTag];
    //将选中的按钮标题设为当前文本框的内容
    NSString *itemStr = [actionSheet buttonTitleAtIndex:buttonIndex];
    inputView.text = itemStr;
}

@end
