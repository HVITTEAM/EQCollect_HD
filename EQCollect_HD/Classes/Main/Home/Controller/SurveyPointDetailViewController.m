//
//  SurveyPointDetailViewController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
#import "SurveyPointDetailViewController.h"
#import "QCSlideSwitchView.h"

#import "PointinfoViewController.h"
#import "AbnormalinfoListController.h"
#import "ReactioninfoListController.h"
#import "DamageinfoListController.h"
#import "AbnormalinfoViewController.h"
#import "ReactioninfoViewController.h"
#import "DamageinfoViewController.h"

@interface SurveyPointDetailViewController ()<QCSlideSwitchViewDelegate>
{
    NSUInteger _currentIndex;         //当前页面的索引号
    UIBarButtonItem *_rightItem;      //导航条上的右侧按钮，当页面为调查点详情时有“编辑”，“完成”两种状态，其它页面都为“新增”
}
@property (strong,nonatomic)QCSlideSwitchView *slideSwitchView;  //滑动视图
@property (strong,nonatomic)NSMutableArray *vcArray;            //存放控制器的数组

@property (strong,nonatomic)AbnormalinfoListController *abnormalinfoListVC;
@property (strong,nonatomic)ReactioninfoListController *reactioninfoListVC;
@property (strong,nonatomic)DamageinfoListController   *damageinfoListVC;
@property (strong,nonatomic)PointinfoViewController *pointinfoVC;

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
    //获取设备当前方向
    UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
    //将UIDeviceOrientation类型转为UIInterfaceOrientation
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)devOrientation;
    //根据屏幕方向设置调查点信息视图的约束
    [self.pointinfoVC rotationToInterfaceOrientation:interfaceOrientation];
}

-(void)initSurveyPointDetail
{
    self.title = @"调查点详情";
    
    _rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rigthItemTap:)];
    //根据是否上传确定显示或隐藏导航栏右侧按钮
    if (![self.pointinfo.upload isEqualToString:@"1"]) {
        self.navigationItem.rightBarButtonItem = _rightItem;
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //创建一组UIViewController作为slideSwitchView的数据源
    self.vcArray = [[NSMutableArray alloc] init];
    
    self.pointinfoVC = [[PointinfoViewController alloc] initWithNibName:@"PointinfoViewController" bundle:nil];
    self.pointinfoVC.title = @"调查点";
    self.pointinfoVC.pointinfo = self.pointinfo;
    
    UISplitViewController *rootVC = (UISplitViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    self.pointinfoVC.delegate = ((UINavigationController *)rootVC.viewControllers[1]).viewControllers[0];
    [self.vcArray addObject:self.pointinfoVC];
    
    self.abnormalinfoListVC = [[AbnormalinfoListController alloc] initWithNibName:@"AbnormalinfoListController" bundle:nil];
    self.abnormalinfoListVC.title = @"宏观异常";
    self.abnormalinfoListVC.nav = self.navigationController;
    self.abnormalinfoListVC.pointid = self.pointinfo.pointid;
    self.abnormalinfoListVC.pointUploadFlag = self.pointinfo.upload;
    [self.vcArray addObject:self.abnormalinfoListVC];
    
    self.reactioninfoListVC = [[ReactioninfoListController alloc] initWithNibName:@"ReactioninfoListController" bundle:nil];
    self.reactioninfoListVC.title = @"人物反应";
    self.reactioninfoListVC.nav = self.navigationController;
    self.reactioninfoListVC.pointid = self.pointinfo.pointid;
    self.reactioninfoListVC.pointUploadFlag = self.pointinfo.upload;
    [self.vcArray addObject:self.reactioninfoListVC];
    
    self.damageinfoListVC = [[DamageinfoListController alloc] initWithNibName:@"DamageinfoListController" bundle:nil];
    self.damageinfoListVC.title = @"房屋震害";
    self.damageinfoListVC.nav = self.navigationController;
    self.damageinfoListVC.pointid = self.pointinfo.pointid;
    self.damageinfoListVC.pointUploadFlag = self.pointinfo.upload;
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
        _rightItem.title = @"编辑";
        self.pointinfoVC.actionType = kActionTypeShow;
    }else {
         _rightItem.title = @"新增";
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
        AbnormalinfoViewController *abnormalVC1 = [[AbnormalinfoViewController alloc] init];
        abnormalVC1.actionType = kActionTypeAdd;
        abnormalVC1.pointid = self.pointinfo.pointid;
        
        abnormalVC1.delegate = self.abnormalinfoListVC;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:abnormalVC1];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];

    }else if (_currentIndex == 2){
        ReactioninfoViewController *reactionifoVC1 = [[ReactioninfoViewController alloc] init];
        reactionifoVC1.actionType = kActionTypeAdd;
        reactionifoVC1.pointid = self.pointinfo.pointid;
        
        reactionifoVC1.delegate = self.reactioninfoListVC;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:reactionifoVC1];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];

    }else if (_currentIndex ==3){
        DamageinfoViewController *damageinfoVC1 = [[DamageinfoViewController alloc] init];
        damageinfoVC1.actionType = kActionTypeAdd;
        damageinfoVC1.pointid = self.pointinfo.pointid;
        
        damageinfoVC1.delegate = self.damageinfoListVC;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:damageinfoVC1];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

-(void)dealloc
{
    NSLog(@"SurveyPointDetailViewController释放了吗。。。。。。。。。。。。。");
}


@end
