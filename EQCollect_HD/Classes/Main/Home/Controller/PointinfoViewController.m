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
#import "PictureInfoTableHelper.h"
#import "PictureMode.h"
#import "LocationHelper.h"

@interface PointinfoViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointidTopCons;        //调查点编号TextField的顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointidWidthCons;      //调查点编号TextField的宽约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;  //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;         //包裹真正内容的容器view

@property (weak, nonatomic) IBOutlet UITextField *pointidTextF;                 //调查点编号
@property (weak, nonatomic) IBOutlet UITextField *earthidTextF;                 //地震编号
@property (weak, nonatomic) IBOutlet UITextField *pointlocationTextF;           //调查点地点
@property (weak, nonatomic) IBOutlet UITextField *pointlonTextF;                //调查点经度
@property (weak, nonatomic) IBOutlet UITextField *pointlatTextF;                //调查点纬度
@property (weak, nonatomic) IBOutlet UITextField *pointnameTextF;               //调查点名称
@property (weak, nonatomic) IBOutlet UITextField *pointtimeTextF;               //生成时间
@property (weak, nonatomic) IBOutlet UITextField *pointgroupTextF;              //小组名称
@property (weak, nonatomic) IBOutlet UITextField *pointPersonTextF;             //小组成员
@property (weak, nonatomic) IBOutlet UITextField *pointintensityTextF;          //评定烈度
@property (weak, nonatomic) IBOutlet UITextView *pointcontentTextV;             //调查简述

@property (strong,nonatomic)NSArray *textInputViews;               //所有的文本输入框      

@end

@implementation PointinfoViewController
{
    CGFloat _navHeight;       // 导航栏与状态栏总的高度
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;
    
    [self initPointinfoVC];
        UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
        //将UIDeviceOrientation类型转为UIInterfaceOrientation
        UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)devOrientation;
        //根据屏幕方向设置视图的约束
        [self rotationToInterfaceOrientation:interfaceOrientation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showPointinfoData];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
//-(void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    //获取设备当前方向
//    UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
//    //将UIDeviceOrientation类型转为UIInterfaceOrientation
//    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)devOrientation;
//    //根据屏幕方向设置视图的约束
//    [self rotationToInterfaceOrientation:interfaceOrientation];
//
//}
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
    self.textInputViews = @[
                            self.pointidTextF,
                            self.pointlocationTextF,
                            self.pointnameTextF,
                            self.pointtimeTextF,
                            self.earthidTextF,
                            self.pointlonTextF,
                            self.pointlatTextF,
                            self.pointgroupTextF,
                            self.pointPersonTextF,
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

/**
 *  显示页面数据
 */
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
        self.pointPersonTextF.text = self.pointinfo.pointperson;
        self.pointintensityTextF.text = self.pointinfo.pointintensity;
        self.pointcontentTextV.text = self.pointinfo.pointcontent;
    }else
    {
        self.pointidTextF.text = [self createUniqueIdWithAbbreTableName:@"DC"];
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        self.pointtimeTextF.text = [formatter stringFromDate:date];
        
        LocationHelper *lHelper = [LocationHelper sharedLocationHelper];
        self.pointlatTextF.text = [NSString stringWithFormat:@"%f",lHelper.currentLocation.coordinate.latitude];
        self.pointlonTextF.text = [NSString stringWithFormat:@"%f",lHelper.currentLocation.coordinate.longitude];
        __weak typeof(self) weakSelf = self;
        [lHelper reverseGeocodeWithSuccess:^(NSString *address) {
            weakSelf.pointlocationTextF.text = address;
        } failure:^{
            [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"无法解析当前地址，您可手动输入地址" delegate:nil
                              cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
        }];
    }
}

///**
// *  重写pointinfo的 setter 方法，当更新pointinfo时，更新页面数据
// */
//-(void)setPointinfo:(PointModel *)pointinfo
//{
//    _pointinfo = pointinfo;
//    [self showPointinfoData];
//}

//-(void)setActionType:(ActionType)actionType
//{
//    _actionType = actionType;
//    [self showPointinfoData];
//}

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
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [super textFieldShouldBeginEditing:textField];
    BOOL canEdit;
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
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [super textViewShouldBeginEditing:textView];
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
    if ([self hasTextBeNull]) {
        return;
    }
    NSString *pointid = self.pointidTextF.text;
    NSString *earthid = self.earthidTextF.text;
    NSString *pointlocation = self.pointlocationTextF.text;
    NSString *pointlon = self.pointlonTextF.text;
    NSString *pointlat = self.pointlatTextF.text;
    NSString *pointname = self.pointnameTextF.text;
    NSString *pointtime = self.pointtimeTextF.text;
    NSString *pointgroup = self.pointgroupTextF.text;
    NSString *pointperson = self.pointPersonTextF.text;
    NSString *pointintensity = self.pointintensityTextF.text;
    NSString *pointcontent = self.pointcontentTextV.text;
    NSString *upload = @"0";

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText = @"请等待...";

    [hud showAnimated:YES whileExecutingBlock:^{
        
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
                              pointperson,@"pointperson",
                              pointintensity,@"pointintensity",
                              pointcontent,@"pointcontent",
                              upload,@"upload",nil];
        
        BOOL result = [[PointinfoTableHelper sharedInstance] insertDataWith:dict];
        if (!result) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.pointidTextF.text = nil;
                self.earthidTextF.text = nil;
                self.pointlocationTextF.text = nil;
                self.pointlonTextF.text = nil;
                self.pointlatTextF.text = nil;
                self.pointnameTextF.text = nil;
                self.pointtimeTextF.text = nil;
                self.pointgroupTextF.text = nil;
                self.pointPersonTextF.text = nil;
                self.pointintensityTextF.text = nil;
                self.pointcontentTextV.text = nil;
                
                [self.view endEditing:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:kAddPointinfoSucceedNotification object:nil];
            });
        }

    } completionBlock:^{
        [hud removeFromSuperview];
        //[hud release];
    }];

    
    
}

-(void)updatePointinfo
{
    if ([self hasTextBeNull]) {
        return;
    }
    
    //NSString *pointid = self.pointinfo.pointid;
    NSString *earthid = self.earthidTextF.text;
    NSString *pointlocation = self.pointlocationTextF.text;
    NSString *pointlon = self.pointlonTextF.text;
    NSString *pointlat = self.pointlatTextF.text;
    NSString *pointname = self.pointnameTextF.text;
    //NSString *pointtime = self.pointtimeTextF.text;
    NSString *pointgroup = self.pointgroupTextF.text;
    NSString *pointperson = self.pointPersonTextF.text;
    NSString *pointintensity = self.pointintensityTextF.text;
    NSString *pointcontent = self.pointcontentTextV.text;
    //NSString *upload = self.pointinfo.upload;

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"请等待...";
    
    [hud showAnimated:YES whileExecutingBlock:^{
        
        //创建字典对象并向表中插和数据
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              self.pointinfo.pointid,@"pointid",
                              earthid,@"earthid",
                              pointlocation,@"pointlocation",
                              pointlon, @"pointlon",
                              pointlat, @"pointlat",
                              pointname,@"pointname",
                              self.pointinfo.pointtime,@"pointtime",
                              pointgroup,@"pointgroup",
                              pointperson,@"pointperson",
                              pointintensity,@"pointintensity",
                              pointcontent,@"pointcontent",
                              self.pointinfo.upload,@"upload",
                              nil];
        
        BOOL result = [[PointinfoTableHelper sharedInstance]updateDataWith:dict];
        if (!result) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view endEditing:YES];
             });

            //[[NSNotificationCenter defaultCenter] postNotificationName:kAddPointinfoSucceedNotification object:nil];
        }
    } completionBlock:^{
        [hud removeFromSuperview];
        //[hud release];
    }];
}

//判断是否有文本框为空
-(BOOL)hasTextBeNull
{
    //判断文本输入框是否为空，如果为空则提示并返回
    for (int i=0; i<self.textInputViews.count; i++) {
        if (i!=self.textInputViews.count-1) {
            UITextField *textF = (UITextField *)self.textInputViews[i];
            if (textF.text ==nil || textF.text.length <=0) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"所填项目不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return YES;
            }
        }else{
            UITextView *textV = (UITextView *)self.textInputViews[i];
            if (textV.text ==nil || textV.text.length <=0) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"数据不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return YES;
            }
        }
    }
    return NO;
}

-(void)dealloc
{
    _pointidTopCons = nil;
    _pointidWidthCons = nil;
    _rootScrollView = nil;
    _containerView = nil;
    
    _pointidTextF = nil;
    _earthidTextF = nil;
    _pointlocationTextF = nil;
    
    _pointlonTextF = nil;
    _pointlatTextF = nil;
    _pointnameTextF = nil;
    _pointtimeTextF = nil;
    _pointgroupTextF = nil;
    _pointintensityTextF = nil;
    _pointcontentTextV = nil;
    _pointPersonTextF = nil;
    
    _pointinfo = nil;
    
    _textInputViews = nil;
    NSLog(@"PointinfoViewController释放了吗。。。。。。。。。。。。。");
}
@end

