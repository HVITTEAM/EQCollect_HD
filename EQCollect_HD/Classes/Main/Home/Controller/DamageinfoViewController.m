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
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
    CGFloat keyBoardHeight;         //键盘高度
    NSUInteger _currentInputViewTag;  //当前文本框的tag
}
@end

@implementation DamageinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initDamageinfo];
    [self showDamageinfoData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

/**
 *  初始化房屋震害信息控制器
 */
-(void)initDamageinfo
{
    self.navigationItem.title = @"房屋震害";
    
    keyBoardHeight = 352;
    //默认有状态栏，高度为64
    _navHeight = kNormalNavHeight;
    //禁用交互
    [self.view setUserInteractionEnabled:NO];
    if (self.isAdd ) {
        //设置导航栏按钮
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(addDamageinfo)];
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

    self.intensityItems = @[@"1级",@"2级",@"3级",@"4级",@"5级",@"6级",@"7级",@"8级",@"9级",@"10级"];
    self.fortificationintensityItems = @[@"1级",@"2级",@"3级",@"4级",@"5级",@"6级",@"7级",@"8级",@"9级",@"10级"];
    self.damagesituationItems = @[@"严重",@"中等",@"轻微"];
    self.damageindexItems = @[@"1级",@"2级",@"3级",@"4级",@"5级",@"6级",@"7级",@"8级",@"9级",@"10级"];
}

-(void)showDamageinfoData
{
    if (!self.isAdd) {
//        self.damageidTextF.text = self.damageinfo.damageid;
//        self.damagetimeTextF.text = self.damageinfo.damagetime;
//        self.damageaddressTextF.text = self.damageinfo.damageaddress;
//        self.damageintensityTextF.text = self.damageinfo.damageintensity;
//        self.zrcorxqTextF.text = self.damageinfo.zrcorxq;
//        self.dworzhTextF.text = self.damageinfo.dworzh;
//        self.fortificationintensityTextF.text = self.damageinfo.fortificationintensity;
//        self.damagesituationTextF.text = self.damageinfo.damagesituation;
//        self.damageindexTextF.text = self.damageinfo.damageindex;
        
        
        self.damageidTextF.text = self.damageinfo[@"damageid"];
        self.damagetimeTextF.text = self.damageinfo[@"damagetime"];
        self.damageaddressTextF.text = self.damageinfo[@"damageaddress"];
        self.damageintensityTextF.text = self.damageinfo[@"damageintensity"];
        self.zrcorxqTextF.text = self.damageinfo[@"zrcorxq"];
        self.dworzhTextF.text = self.damageinfo[@"dworzh"];
        self.fortificationintensityTextF.text = self.damageinfo[@"fortificationintensity"];
        self.damagesituationTextF.text = self.damageinfo[@"damagesituation"];
        self.damageindexTextF.text = self.damageinfo[@"damageindex"];

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

    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)&& !self.isAdd)
    {
        //设备为横屏且不是新增界面，设置为横屏约束
        self.damageidWidthCons.constant = 180;
    }else{
        //设备为竖屏或新增界面，设置为竖屏约束
        self.damageidWidthCons.constant = 100;
    }
    self.damageidTopCons.constant = 20+_navHeight;
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
        case 1004:
            canEdit = NO;
            [self showActionSheetWithTextField:textField items:self.intensityItems];
            break;
        case 1005:
            canEdit = NO;
            [self showActionSheetWithTextField:textField items:self.fortificationintensityItems];
            break;
        case 1006:
            canEdit = NO;
            [self showActionSheetWithTextField:textField items:self.damagesituationItems];
            break;
        case 1007:
            canEdit = NO;
            [self showActionSheetWithTextField:textField items:self.damageindexItems];
            break;
        default:
            canEdit = YES;
            break;
    }
    return canEdit;
}

/**
 *  新增房屋震害信息
 */
-(void)addDamageinfo
{
    NSString *damageid = self.damageidTextF.text;
    NSString *damagetime = self.damagetimeTextF.text;
    NSString *damageaddress = self.damageaddressTextF.text;
    NSString *damageintensity = self.damageintensityTextF.text;
    NSString *zrcorxq = self.zrcorxqTextF.text;
    NSString *dworzh = self.dworzhTextF.text;
    NSString *fortificationintensity = self.fortificationintensityTextF.text;
    NSString *damagesituation = self.damagesituationTextF.text;
    NSString *damageindex = self.damageindexTextF.text;
    
    
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
                          damageid,@"damageid",
                          damagetime,@"damagetime",
                          damageaddress,@"damageaddress",
                          damageintensity, @"damageintensity",
                          zrcorxq, @"zrcorxq",
                          dworzh,@"dworzh",
                          fortificationintensity,@"fortificationintensity",
                          damagesituation,@"damagesituation",
                          damageindex,@"damageindex",
                          self.pointid,@"pointid",
                          nil];
    
    BOOL result = [[DamageinfoTableHelper sharedInstance] insertDataWith:dict];
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
