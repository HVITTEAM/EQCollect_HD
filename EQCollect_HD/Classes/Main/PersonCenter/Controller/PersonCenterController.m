//
//  PersonCenterController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/2.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "PersonCenterController.h"
#import "HMCommonCenterItem.h"
#import "HMCommonTextfieldItem.h"

@interface SettingViewController ()


@end

@implementation PersonCenterController
{
    NSIndexPath *_cIndexPath;
    UserModel *_userinfo;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userinfo = [ArchiverCacheHelper getLocaldataBykey:User_Archiver_Key filePath:User_Archiver_Path];
    
    [self initNavigation];
    
    [self setupGroups];
    
    self.tableView.rowHeight = 50;
}

/**
 
 *  初始化导航栏 */
-(void)initNavigation
{
    self.title = @"个人中心";
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
    [self setupGroup1];
    [self setupFooter];
    
    //刷新表格
    [self.tableView reloadData];
}
- (void)setupGroup0
{
    // 1.创建组
    HMCommonGroup *group = [HMCommonGroup group];
    [self.groups addObject:group];
    
    // 设置组的所有行数据
    HMCommonTextfieldItem *userccount = [HMCommonTextfieldItem itemWithTitle:@"用户名"];
    userccount.placeholder = _userinfo.userccount;
    
    HMCommonTextfieldItem *username = [HMCommonTextfieldItem itemWithTitle:@"用户名"];
    username.placeholder = _userinfo.username;

    HMCommonTextfieldItem *userpwd = [HMCommonTextfieldItem itemWithTitle:@"密码"];
    userpwd.placeholder = _userinfo.userpwd;

    HMCommonTextfieldItem *usertel = [HMCommonTextfieldItem itemWithTitle:@"电话"];
    usertel.placeholder = _userinfo.usertel;

//    HMCommonCenterItem *groupname = [HMCommonCenterItem itemWithTitle:@"所在分组" icon:nil];
//    groupname.centerString = @"第一组";
    
    group.items = @[userccount,username,userpwd,usertel];
}

- (void)setupGroup1
{
    // 1.创建组
    HMCommonGroup *group = [HMCommonGroup group];
    [self.groups addObject:group];
    
    // 设置组的所有行数据
    HMCommonTextfieldItem *useraddress = [HMCommonTextfieldItem itemWithTitle:@"地址"];
    useraddress.placeholder = _userinfo.useraddress;
    
    HMCommonTextfieldItem *userlon = [HMCommonTextfieldItem itemWithTitle:@"经度"];
    userlon.placeholder = _userinfo.userlon;
    
    HMCommonTextfieldItem *userlat = [HMCommonTextfieldItem itemWithTitle:@"纬度"];
    userlat.placeholder = _userinfo.userlat;
    
    HMCommonTextfieldItem *jobname = [HMCommonTextfieldItem itemWithTitle:@"工作名称"];
    jobname.placeholder = _userinfo.jobname;
    
    
    HMCommonTextfieldItem *groupname = [HMCommonTextfieldItem itemWithTitle:@"所在分组"];
    groupname.placeholder = _userinfo.groupname;
    //    HMCommonCenterItem *groupname = [HMCommonCenterItem itemWithTitle:@"所在分组" icon:nil];
    //    groupname.centerString = @"第一组";
    
    group.items = @[useraddress,userlon,userlat,jobname,groupname];
}

- (void)setupFooter
{
    // 1.创建按钮
    UIButton *logout = [[UIButton alloc] init];
    
    // 2.设置属性
    logout.titleLabel.font = [UIFont systemFontOfSize:16];
    [logout setTitle:@"确定修改" forState:UIControlStateNormal];
    [logout setTitleColor:HMColor(255, 10, 10) forState:UIControlStateNormal];
    [logout setBackgroundImage:[UIImage resizedImage:@"common_card_background"] forState:UIControlStateNormal];
    [logout setBackgroundImage:[UIImage resizedImage:@"common_card_background_highlighted"] forState:UIControlStateHighlighted];
    [logout addTarget:self action:@selector(updateuserInfo) forControlEvents:UIControlEventTouchUpInside];
    
    // 3.设置尺寸(tableFooterView和tableHeaderView的宽度跟tableView的宽度一样)
    logout.height = 60;
    
    self.tableView.tableFooterView = logout;
    
}


-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)updateuserInfo
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
