//
//  SurveyPointDetailViewController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
#import "SurveyPointDetailViewController.h"

@interface SurveyPointDetailViewController ()

@end

@implementation SurveyPointDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"调查点详情";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //创建一组UIViewController作为slideSwitchView的数据源
    self.vcArray = [[NSMutableArray alloc] init];
    
    self.pointinfoVC = [[PointinfoViewController alloc] initWithNibName:@"PointinfoViewController" bundle:nil];
    self.pointinfoVC.title = @"调查点信息";
    self.pointinfoVC.surveyPointDetailView = self.view;
    [self.vcArray addObject:self.pointinfoVC];
    
    self.abnormalinfoListVC = [[AbnormalinfoListController alloc] initWithNibName:@"AbnormalinfoListController" bundle:nil];
    self.abnormalinfoListVC.title = @"宏观异常信息";
    self.abnormalinfoListVC.nav = self.navigationController;
    [self.vcArray addObject:self.abnormalinfoListVC];
    
    self.reactioninfoListVC = [[ReactioninfoListController alloc] initWithNibName:@"ReactioninfoListController" bundle:nil];
    self.reactioninfoListVC.title = @"人物反应信息";
    self.reactioninfoListVC.nav = self.navigationController;
    [self.vcArray addObject:self.reactioninfoListVC];
    
    self.damageinfoListVC = [[DamageinfoListController alloc] initWithNibName:@"DamageinfoListController" bundle:nil];
    self.damageinfoListVC.title = @"房屋震害信息";
    self.damageinfoListVC.nav = self.navigationController;
    [self.vcArray addObject:self.damageinfoListVC];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //初始化slideSwitchView
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*下面三行代码防止在另外界面进行旋转，返回此界面时调查点信息界面不更新*/
    //获取设备当前方向
    UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
    //将UIDeviceOrientation类型转为UIInterfaceOrientation
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)devOrientation;
    //根据屏幕方向设置调查点信息视图的约束
    [self.pointinfoVC rotationToInterfaceOrientation:interfaceOrientation];
}

/**
 *  初始化slideSwitchView
 */
-(void)initView
{
    if (self.slideSwitchView)
    {
        self.slideSwitchView.frame = CGRectMake(0,64,self.view.width,self.view.height-64);
    }
    else
    {
        self.slideSwitchView = [[QCSlideSwitchView alloc]initWithFrame:CGRectMake(0,64,self.view.width,self.view.height-64)];
        self.slideSwitchView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.slideSwitchView.slideSwitchViewDelegate = self;
        [self.view addSubview:self.slideSwitchView];
        self.slideSwitchView.tabItemNormalColor = [QCSlideSwitchView colorFromHexRGB:@"868686"];
        self.slideSwitchView.tabItemSelectedColor = [QCSlideSwitchView colorFromHexRGB:@"1e90ff"];
        self.slideSwitchView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow"]
                                            stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
        [self.slideSwitchView buildUI];
    }
}

#pragma mark SlideSwitchView协议方法
-(NSUInteger)numberOfTab:(QCSlideSwitchView *)view
{
    return 4;
}

- (UIViewController *)slideSwitchView:(QCSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    return self.vcArray[number];
}

- (void)slideSwitchView:(QCSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    NSLog(@"选中了%lu",(unsigned long)number);
}

//处理屏幕旋转
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    //旋转调查点信息界面
    [self.pointinfoVC rotationToInterfaceOrientation:interfaceOrientation];
}


@end
