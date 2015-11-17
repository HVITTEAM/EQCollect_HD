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

@interface PersonCenterController ()


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
    if (!_userinfo) {
        _userinfo = [[UserModel alloc] init];
    }
    
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
    HMCommonTextfieldItem *userccount = [HMCommonTextfieldItem itemWithTitle:@"帐号"];
    userccount.placeholder = @"请输入帐号";
    userccount.textString = _userinfo.userccount;
    //userccount.textString = @"123456";
    
    HMCommonTextfieldItem *username = [HMCommonTextfieldItem itemWithTitle:@"名称"];
    username.placeholder = @"请输入名称";
    username.textString = _userinfo.username;
    //username.textString = @" admin";
    
    HMCommonTextfieldItem *userpwd = [HMCommonTextfieldItem itemWithTitle:@"密码"];
    [userpwd.rightText setSecureTextEntry:YES];
    userpwd.placeholder = @"请输入密码";
    userpwd.textString = _userinfo.userpwd;
    //userpwd.textString = @"hvit";

    HMCommonTextfieldItem *usertel = [HMCommonTextfieldItem itemWithTitle:@"电话"];
    usertel.placeholder = @"请输入电话";
    usertel.textString = _userinfo.usertel;
    //usertel.textString = @"88888888";

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

    HMCommonTextfieldItem *groupname = [HMCommonTextfieldItem itemWithTitle:@"所在分组"];
    groupname.placeholder = @"输入分组名称";
    groupname.textString = _userinfo. pointgroup;
    
    HMCommonTextfieldItem *persons = [HMCommonTextfieldItem itemWithTitle:@"小组成员"];
    persons.placeholder = @"输入分组成员";
    persons.textString = _userinfo. pointperson;
    
    group.items = @[groupname,persons];
}


- (void)setupFooter
{
    // 1.创建按钮
    UIButton *logout = [[UIButton alloc] init];
    
    // 2.设置属性
    logout.titleLabel.font = [UIFont systemFontOfSize:16];
    [logout setTitle:@"修改" forState:UIControlStateNormal];
    [logout setTitleColor:HMColor(255, 10, 10) forState:UIControlStateNormal];
    [logout setBackgroundImage:[UIImage resizedImage:@"common_card_background"] forState:UIControlStateNormal];
    [logout setBackgroundImage:[UIImage resizedImage:@"common_card_background_highlighted"] forState:UIControlStateHighlighted];
    [logout addTarget:self action:@selector(modifyUserInfo) forControlEvents:UIControlEventTouchUpInside];
    
    // 3.设置尺寸(tableFooterView和tableHeaderView的宽度跟tableView的宽度一样)
    logout.height = 60;
    
    self.tableView.tableFooterView = logout;
    
}

-(void)modifyUserInfo
{
    HMCommonGroup *group0 = self.groups[0];
    HMCommonGroup *group1 = self.groups[1];
    
    NSString *userccount = ((HMCommonTextfieldItem *)group0.items[0]).rightText.text;
    NSString *username = ((HMCommonTextfieldItem *)group0.items[1]).rightText.text;
    NSString *userpwd = ((HMCommonTextfieldItem *)group0.items[2]).rightText.text;
    NSString *usertel = ((HMCommonTextfieldItem *)group0.items[3]).rightText.text;
    NSString *pointgroup = ((HMCommonTextfieldItem *)group1.items[0]).rightText.text;
    NSString *pointperson = ((HMCommonTextfieldItem *)group1.items[1]).rightText.text;
    
    _userinfo.userccount = userccount;
    _userinfo.username = username;
    _userinfo.userpwd = userpwd;
    _userinfo.usertel = usertel;
    _userinfo.pointgroup = pointgroup;
    _userinfo.pointperson = pointperson;
    
    [ArchiverCacheHelper saveObjectToLoacl:_userinfo key:User_Archiver_Key filePath:User_Archiver_Path];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    

}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
