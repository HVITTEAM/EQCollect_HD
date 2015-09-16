//
//  ReactioninfoViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
#define kNormalNavHeight 64
#define kAddNavheight 44
#import "ReactioninfoViewController.h"

@interface ReactioninfoViewController ()
{
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
    CGFloat keyBoardHeight;         //键盘高度
    NSUInteger _currentInputViewTag;  //当前文本框的tag
}
@end

@implementation ReactioninfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initReactioninfoVC];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
     [self showReactioninfoData];
}

/**
 *  初始化人物反应信息控制器
 */
-(void)initReactioninfoVC
{
    self.navigationItem.title = @"人物反应";
    
    keyBoardHeight = 352;
    //默认有状态栏，高度为64
    _navHeight = kNormalNavHeight;
    //禁用交互
    [self.view setUserInteractionEnabled:NO];
    if (self.isAdd ) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(addReactioninfo)];
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
                            self.reactionidTextF,
                            self.reactiontimeTextF,
                            self.informantnameTextF,
                            self.informantageTextF,
                            self.informanteducationTextF,
                            self.informantjobTextF,
                            self.reactionaddressTextF,
                            self.rockfeelingTextF,
                            self.throwfeelingTextF,
                            self.throwtingsTextF,
                            self.throwdistanceTextF,
                            self.fallTextF,
                            self.hangTextF,
                            self.furnituresoundTextF,
                            self.furnituredumpTextF,
                            self.soundsizeTextF,
                            self.sounddirectionTextF
                            ];
    for (int i = 0;i<self.textInputViews.count;i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }

    self.educationItems = @[@"博士",@"研究生",@"大学",@"中学",@"小学",@"其它"];
    self.rockfeelingItems =@[@"强烈",@"中等",@"微弱",@"无感觉"];
    self.throwfeelingItems = @[@"强烈",@"中等",@"微弱",@"无感觉"];
    self.throwtingsItems = @[@"砖石块",@"茶杯",@"水壶",@"小家具",@"其它"];
    self.fallItems = @[@"少量",@"部分",@"多数",@"全部"];
    self.hangItems = @[@"电灯摆动",@"墙上挂画,乐器,小型家俱掉下来"];
    self.furnituresoundItems = @[@"轻微",@"较响",@"剧烈"];
    self.soundsizeItems = @[@"强烈",@"中等",@"微弱",@"无地声"];
    self.sounddirectionItems = @[@"东",@"南",@"西",@"北",@"东南",@"西北",@"西南",@"东北"];
}

-(void)showReactioninfoData
{
    if (!self.isAdd) {
        self.reactionidTextF.text = self.reactioninfo.reactionid;
        self.reactiontimeTextF.text= self.reactioninfo.reactiontime;
        self.informantnameTextF.text= self.reactioninfo.informantname;
        self.informantageTextF.text= self.reactioninfo.informantage;
        self.informanteducationTextF.text= self.reactioninfo.informanteducation;
        self.informantjobTextF.text= self.reactioninfo.informantjob;
        self.reactionaddressTextF.text= self.reactioninfo.reactionaddress;
        self.rockfeelingTextF.text= self.reactioninfo.rockfeeling;
        self.throwfeelingTextF.text= self.reactioninfo.throwfeeling;
        self.throwtingsTextF.text= self.reactioninfo.throwtings;
        self.throwdistanceTextF.text= self.reactioninfo.throwdistance;
        self.fallTextF.text= self.reactioninfo.fall;
        self.hangTextF.text= self.reactioninfo.hang;
        self.furnituresoundTextF.text= self.reactioninfo.furnituresound;
        self.furnituredumpTextF.text= self.reactioninfo.furnituredump;
        self.soundsizeTextF.text= self.reactioninfo.soundsize;
        self.sounddirectionTextF.text= self.reactioninfo.sounddirection;
    }else {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        self.reactiontimeTextF.text = [formatter stringFromDate:date];
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
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation) && !self.isAdd)
    {
        //设备为横屏且不是新增界面，设置为横屏约束
        self.reactionidWidthCons.constant = 180;
    }else{
        //设备为竖屏或新增界面，设置为竖屏约束
        self.reactionidWidthCons.constant = 100;
    }
    self.reactionidTopCons.constant = 20+_navHeight;
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
        case 1001:
            canEdit = NO;
            break;
        case 1004:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.educationItems];
            break;
        case 1007:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.rockfeelingItems];
            break;
        case 1008:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.throwfeelingItems];
            break;
        case 1009:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.throwtingsItems];
            break;
        case 1011:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.fallItems];
            break;
        case 1012:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.hangItems];
            break;
        case 1013:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.furnituresoundItems];
            break;
        case 1015:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.soundsizeItems];
            break;
        case 1016:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.sounddirectionItems];
            break;
        default:
            canEdit = YES;
            break;
    }
    return canEdit;
}

-(void)addReactioninfo
{
    NSString *reactionid = self.reactionidTextF.text;
    NSString *reactiontime = self.reactiontimeTextF.text;
    NSString *informantname = self.informantnameTextF.text;
    NSString *informantage = self.informantageTextF.text;
    NSString *informanteducation = self.informanteducationTextF.text;
    NSString *informantjob = self.informantjobTextF.text;
    NSString *reactionaddress = self.reactionaddressTextF.text;
    NSString *rockfeeling = self.rockfeelingTextF.text;
    NSString *throwfeeling = self.throwfeelingTextF.text;
    NSString *throwtings = self.throwtingsTextF.text;
    NSString *throwdistance = self.throwdistanceTextF.text;
    NSString *fall = self.fallTextF.text;
    NSString *hang = self.hangTextF.text;
    NSString *furnituresound = self.furnituresoundTextF.text;
    NSString *furnituredump = self.furnituredumpTextF.text;
    NSString *soundsize = self.soundsizeTextF.text;
    NSString *sounddirection = self.sounddirectionTextF.text;
   
    
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
                          reactionid,@"reactionid",
                          reactiontime,@"reactiontime",
                          informantname,@"informantname",
                          informantage, @"informantage",
                          informanteducation, @"informanteducation",
                          informantjob,@"informantjob",
                          reactionaddress,@"reactionaddress",
                          rockfeeling,@"rockfeeling",
                          throwfeeling,@"throwfeeling",
                          throwtings,@"throwtings",
                          throwdistance,@"throwdistance",
                          fall,@"fall",
                          hang,@"hang",
                          furnituresound,@"furnituresound",
                          furnituredump,@"furnituredump",
                          soundsize,@"soundsize",
                          sounddirection,@"sounddirection",
                          self.pointid,@"pointid",
                          nil];
    
    BOOL result = [[ReactioninfoTableHelper sharedInstance] insertDataWith:dict];
    if (!result) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错,请确定编号唯一" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{
        self.reactionidTextF.text = nil;
        self.reactiontimeTextF.text = nil;
        self.informantnameTextF.text = nil;
        self.informantageTextF.text = nil;
        self.informanteducationTextF.text = nil;
        self.informantjobTextF.text = nil;
        self.reactionaddressTextF.text = nil;
        self.rockfeelingTextF.text = nil;
        self.throwfeelingTextF.text = nil;
        self.throwtingsTextF.text = nil;
        self.throwdistanceTextF.text = nil;
        self.fallTextF.text = nil;
        self.hangTextF.text = nil;
        self.furnituresoundTextF.text = nil;
        self.furnituredumpTextF.text = nil;
        self.soundsizeTextF.text = nil;
        self.sounddirectionTextF.text = nil;

        [[NSNotificationCenter defaultCenter] postNotificationName:kAddReactioninfoSucceedNotification object:nil];
    }

    
    [self dismissViewControllerAnimated:self completion:nil];
}

-(void)back
{
    [self dismissViewControllerAnimated:self completion:nil];
}

/**
 *  使用UIAlertView向文本框输入内容
 *
 *  @param textField 需要输入内容的文本框
 *  @param items     选项数组
 */
-(void)showAlertViewWithTextField:(UITextField *)textField items:(NSArray *)items
{
    [self.view endEditing:YES];
    //创建UIAlertView并设置标题
    NSString *titleStr = [NSString stringWithFormat:@"%@选项",textField.placeholder];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:titleStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    //添加AlertView控件上的按钮
    for (NSString *buttonTitle in items) {
        [alert addButtonWithTitle:buttonTitle];
    }
    //显示AlertView控件
    [alert show];
}

#pragma mark UIAlertViewDelegate方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *inputView = (UITextField *)[self.view viewWithTag:_currentInputViewTag];
    //将选中的按钮标题设为当前文本框的内容
    NSString *itemStr = [alertView buttonTitleAtIndex:buttonIndex];
    inputView.text = itemStr;
}

@end
