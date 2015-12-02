//
//  SettingViewController.m
//  QinQingBao
//
//  Created by 董徐维 on 15/8/25.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "SettingViewController.h"
#import "LocationHelper.h"
#import "VersionViewController.h"
#import "UseHelpViewController.h"
#import "FeedbackViewController.h"
#import "AppDelegate.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavigation];
    
    [self setupGroups];
    
    self.tableView.rowHeight = 50;
}

/**
 *  初始化导航栏
 */
-(void)initNavigation
{
    self.title = @"系统设置";
    self.view.backgroundColor = HMGlobalBg;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}


# pragma  mark 设置数据源
/**
 *  初始化模型数据
 */
- (void)setupGroups
{
    //每次刷新数据源的时候需要将数据源清空
    [self.groups removeAllObjects];
    
    //重置数据源
    //[self setupGroup0];
    [self setupGroup1];
    
    [self setupFooter];
    
    //刷新表格
    [self.tableView reloadData];
}
//- (void)setupGroup0
//{
//    // 1.创建组
//    HMCommonGroup *group = [HMCommonGroup group];
//    [self.groups addObject:group];
//    
//    // 设置组的所有行数据
//    HMCommonArrowItem *account = [HMCommonArrowItem itemWithTitle:@"帐号管理" icon:nil];
//    // newFriend.destVcClass = [MyAccountViewController class];
//    account.operation = ^{
//    };
//    group.items = @[account];
//}

- (void)setupGroup1
{
    // 1.创建组
    HMCommonGroup *group = [HMCommonGroup group];
    [self.groups addObject:group];
    
    // 设置组的所有行数据
    HMCommonArrowItem *version = [HMCommonArrowItem itemWithTitle:@"版本信息" icon:nil];
    version.destVcClass = [VersionViewController class];
    version.operation = ^{
    };
    
    HMCommonArrowItem *help = [HMCommonArrowItem itemWithTitle:@"使用帮助" icon:nil];
    help.destVcClass = [UseHelpViewController class];
    
    HMCommonArrowItem *advice = [HMCommonArrowItem itemWithTitle:@"意见反馈" icon:nil];
    advice.destVcClass = [FeedbackViewController class];
    
    group.items = @[version,help,advice];
}


- (void)setupFooter
{
    // 1.创建按钮
    UIButton *logout = [[UIButton alloc] init];
    
    // 2.设置属性
    logout.titleLabel.font = [UIFont systemFontOfSize:16];
    [logout setTitle:@"退出当前帐号" forState:UIControlStateNormal];
    [logout setTitleColor:HMColor(255, 10, 10) forState:UIControlStateNormal];
    [logout setBackgroundImage:[UIImage resizedImage:@"common_card_background"] forState:UIControlStateNormal];
    [logout setBackgroundImage:[UIImage resizedImage:@"common_card_background_highlighted"] forState:UIControlStateHighlighted];
    [logout addTarget:self action:@selector(loginOut) forControlEvents:UIControlEventTouchUpInside];
    
    // 3.设置尺寸(tableFooterView和tableHeaderView的宽度跟tableView的宽度一样)
    logout.height = 60;
    
    self.tableView.tableFooterView = logout;
    
}


-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loginOut
{
    AppDelegate *appdl = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdl removeTimer];
    [ArchiverCacheHelper removeLocaldataByFilePath:User_Archiver_Path];
    [HMControllerTool setLoginViewController];
}

@end
