//
//  PersonCenterController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/2.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "PersonCenterController.h"
#import "HMCommonTextfieldItem.h"
#import "CurrentUser.h"

@interface PersonCenterController ()

@end

@implementation PersonCenterController

#pragma mark -- 生命周期方法 --

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavigation];
    
    [self setupGroups];
    
    self.tableView.rowHeight = 50;
}

#pragma mark -- 初始化方法 --
/**
 *  初始化导航栏
 */
-(void)initNavigation
{
    self.title = @"个人中心";
    self.view.backgroundColor = HMGlobalBg;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

#pragma mark -- 协议方法 --

#pragma mark tableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.userInteractionEnabled = NO;
    }
    
    return cell;
}

# pragma  mark -- 设置数据源 --
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
    // 创建组
    HMCommonGroup *group = [HMCommonGroup group];
    [self.groups addObject:group];
    
    // 设置组的所有行数据
    HMCommonTextfieldItem *userccount = [HMCommonTextfieldItem itemWithTitle:@"帐号"];
    userccount.placeholder = nil;
    userccount.textString = [CurrentUser shareInstance].userccount;
    
    HMCommonTextfieldItem *username = [HMCommonTextfieldItem itemWithTitle:@"名称"];
    username.placeholder = nil;
    username.textString = [CurrentUser shareInstance].username;
    
    HMCommonTextfieldItem *usertel = [HMCommonTextfieldItem itemWithTitle:@"电话"];
    usertel.placeholder = nil;
    usertel.textString = [CurrentUser shareInstance].usertel;
    
    group.items = @[userccount,username,usertel];
}

- (void)setupGroup1
{
    // 创建组
    HMCommonGroup *group = [HMCommonGroup group];
    [self.groups addObject:group];
    
    // 设置组的所有行数据
    HMCommonTextfieldItem *groupname = [HMCommonTextfieldItem itemWithTitle:@"所在分组"];
    groupname.placeholder = @"输入所在的组";
    groupname.textString = [CurrentUser shareInstance].pointgroup;
    
    HMCommonTextfieldItem *persons = [HMCommonTextfieldItem itemWithTitle:@"小组成员"];
    persons.placeholder = @"输入小组成员名称,以逗号分隔";
    persons.textString = [CurrentUser shareInstance].pointperson;
    
    group.items = @[groupname,persons];
}

- (void)setupFooter
{
    // 创建按钮
    UIButton *logout = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1, 60)];
    logout.titleLabel.font = [UIFont systemFontOfSize:16];
    [logout setTitle:@"完成" forState:UIControlStateNormal];
    [logout setTitleColor:HMColor(255, 10, 10) forState:UIControlStateNormal];
    [logout setBackgroundImage:[UIImage resizedImage:@"common_card_background"] forState:UIControlStateNormal];
    [logout setBackgroundImage:[UIImage resizedImage:@"common_card_background_highlighted"] forState:UIControlStateHighlighted];
    [logout addTarget:self action:@selector(modifyUserInfo) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = logout;
}

#pragma mark -- 事件方法 --
/**
 *  修改当前用户信息
 */
-(void)modifyUserInfo
{
    HMCommonGroup *group1 = self.groups[1];
    
    NSString *pointgroup = ((HMCommonTextfieldItem *)group1.items[0]).rightText.text;
    NSString *pointperson = ((HMCommonTextfieldItem *)group1.items[1]).rightText.text;
    
    [CurrentUser shareInstance].pointgroup = pointgroup;
    [CurrentUser shareInstance].pointperson = pointperson;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
