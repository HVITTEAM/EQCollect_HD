//
//  SurveyPointDetailViewController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
#import "SurveyPointDetailViewController.h"

#import "PointinfoViewController.h"
#import "AbnormalinfoListController.h"
#import "ReactioninfoListController.h"
#import "DamageinfoListController.h"
#import "AbnormalinfoViewController.h"
#import "ReactioninfoViewController.h"
#import "DamageinfoViewController.h"

@interface SurveyPointDetailViewController ()
{
    NSUInteger _currentIndex;         //当前页面的索引号
    UIBarButtonItem *_rightItem;      //导航条上的右侧按钮，当页面为调查点详情时有“编辑”，“完成”两种状态，其它页面都为“新增”
}
@end

@implementation SurveyPointDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //初始化调查点详情界面
    [self initSurveyPointDetail];
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
    
    //获取设备当前方向
    UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
    //将UIDeviceOrientation类型转为UIInterfaceOrientation
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)devOrientation;
    //根据屏幕方向设置调查点信息视图的约束
    [self.pointinfoVC rotationToInterfaceOrientation:interfaceOrientation];
    
    //根据是否上传确定显示或隐藏导航栏右侧按钮
    if ([self.pointinfo.upload isEqualToString:@"0"]) {
        self.navigationItem.rightBarButtonItem = _rightItem;
    }else {
        self.navigationItem.rightBarButtonItem = _rightItem;
    }
    
    //更新数据
    self.pointinfoVC.pointinfo = self.pointinfo;
    [self.pointinfoVC viewWillAppear:YES];
    
    self.abnormalinfoListVC.pointid = self.pointinfo.pointid;
    [self.abnormalinfoListVC viewWillAppear:YES];
    
    self.reactioninfoListVC.pointid = self.pointinfo.pointid;
    [self.reactioninfoListVC viewWillAppear:YES];
    
     self.damageinfoListVC.pointid = self.pointinfo.pointid;
    [self.damageinfoListVC viewWillAppear:YES];
}

-(void)initSurveyPointDetail
{
    self.title = @"调查点详情";
    
    _rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rigthItemTap:)];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //创建一组UIViewController作为slideSwitchView的数据源
    self.vcArray = [[NSMutableArray alloc] init];
    
    self.pointinfoVC = [[PointinfoViewController alloc] initWithNibName:@"PointinfoViewController" bundle:nil];
    self.pointinfoVC.title = @"调查点";
    [self.vcArray addObject:self.pointinfoVC];
    
    self.abnormalinfoListVC = [[AbnormalinfoListController alloc] initWithNibName:@"AbnormalinfoListController" bundle:nil];
    self.abnormalinfoListVC.title = @"宏观异常";
    self.abnormalinfoListVC.nav = self.navigationController;
    [self.vcArray addObject:self.abnormalinfoListVC];
    
    self.reactioninfoListVC = [[ReactioninfoListController alloc] initWithNibName:@"ReactioninfoListController" bundle:nil];
    self.reactioninfoListVC.title = @"人物反应";
    self.reactioninfoListVC.nav = self.navigationController;
    [self.vcArray addObject:self.reactioninfoListVC];
    
    self.damageinfoListVC = [[DamageinfoListController alloc] initWithNibName:@"DamageinfoListController" bundle:nil];
    self.damageinfoListVC.title = @"房屋震害";
    self.damageinfoListVC.nav = self.navigationController;
    [self.vcArray addObject:self.damageinfoListVC];
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
    if (number == 0) {
        
        if ([self.pointinfo.upload isEqualToString:@"0"]) {
            _rightItem.title = @"编辑";
            self.navigationItem.rightBarButtonItem = _rightItem;
        }else self.navigationItem.rightBarButtonItem = nil;
    }else {
         _rightItem.title = @"新增";
        self.navigationItem.rightBarButtonItem = _rightItem;
    }
    _currentIndex = number;
}

//处理屏幕旋转
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    //旋转调查点信息界面
    [self.pointinfoVC rotationToInterfaceOrientation:interfaceOrientation];
}

-(void)rigthItemTap:(id)sender
{
    if (_currentIndex == 0) {
        if ([_rightItem.title isEqualToString:@"编辑"]) {
            _rightItem.title = @"确定";
            self.pointinfoVC.actionType = kactionTypeEdit;
        }else{
            _rightItem.title = @"编辑";
            self.pointinfoVC.actionType = kActionTypeShow;
            //更新数据
            [self.pointinfoVC updatePointinfo];
        }
    }else if (_currentIndex == 1) {
        if (!self.abnormalVC) {
            self.abnormalVC = [[AbnormalinfoViewController alloc] init];
        }
        self.abnormalVC.actionType = kActionTypeAdd;
        self.abnormalVC.pointid = self.pointinfo.pointid;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.abnormalVC];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
    }else if (_currentIndex == 2){
        if (!self.reactionifoVC) {
            self.reactionifoVC = [[ReactioninfoViewController alloc] init];
        }
        self.reactionifoVC.actionType = kActionTypeAdd;
        self.reactionifoVC.pointid = self.pointinfo.pointid;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.reactionifoVC];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
    }else if (_currentIndex ==3){
        if (!self.damageinfoVC) {
            self.damageinfoVC = [[DamageinfoViewController alloc] init];
        }
        self.damageinfoVC.actionType = kActionTypeAdd;
        self.damageinfoVC.pointid = self.pointinfo.pointid;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.damageinfoVC];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

@end
