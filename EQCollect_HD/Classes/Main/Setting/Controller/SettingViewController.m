//
//  SettingViewController.m
//  QinQingBao
//
//  Created by 董徐维 on 15/8/25.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "SettingViewController.h"

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
    [self setupGroup0];
    
    //刷新表格
    [self.tableView reloadData];
}

- (void)setupGroup0
{
    // 1.创建组
    HMCommonGroup *group = [HMCommonGroup group];
    [self.groups addObject:group];
    
    // 设置组的所有行数据
    HMCommonArrowItem *version = [HMCommonArrowItem itemWithTitle:@"设置" icon:@"pc_accout.png"];
    // newFriend.destVcClass = [MyAccountViewController class];
    version.operation = ^{
    };
    
    HMCommonArrowItem *help = [HMCommonArrowItem itemWithTitle:@"设置" icon:@"app.png"];
    
    HMCommonArrowItem *advice = [HMCommonArrowItem itemWithTitle:@"设置" icon:@"app.png"];
    
    group.items = @[version,help,advice];
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
