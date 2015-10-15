//
//  PersonCenterController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/2.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "PersonCenterController.h"
#import "HMCommonCenterItem.h"
@interface SettingViewController ()

@end

@implementation PersonCenterController

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
    
    //刷新表格
    [self.tableView reloadData];
}
- (void)setupGroup0
{
    // 1.创建组
    HMCommonGroup *group = [HMCommonGroup group];
    [self.groups addObject:group];
    
    // 设置组的所有行数据
    HMCommonCenterItem *userccount = [HMCommonCenterItem itemWithTitle:@"帐号" icon:nil];
    userccount.centerString = @"1234567890";
    
    HMCommonCenterItem * username = [HMCommonCenterItem itemWithTitle:@"用户名" icon:nil];
    username.centerString = @"大猫";
    username.operation = ^{
        
    };

    HMCommonCenterItem *useraddress = [HMCommonCenterItem itemWithTitle:@"地址" icon:nil];
    useraddress.centerString = @"浙江省杭州市建德市建德村";

    HMCommonCenterItem *userlon = [HMCommonCenterItem itemWithTitle:@"当前经度" icon:nil];
    userlon.centerString = @"120.000";
    
    HMCommonCenterItem *userlat = [HMCommonCenterItem itemWithTitle:@"当前纬度" icon:nil];
    userlat.centerString = @"31.00";

    HMCommonCenterItem *usertel = [HMCommonCenterItem itemWithTitle:@"电话" icon:nil];
    usertel.centerString = @"12788888888";
    
    HMCommonCenterItem *jobname = [HMCommonCenterItem itemWithTitle:@"工作" icon:nil];
    jobname.centerString = @"当官的";
    
    HMCommonCenterItem *groupname = [HMCommonCenterItem itemWithTitle:@"所在分组" icon:nil];
    groupname.centerString = @"第一组";
    
    group.items = @[userccount,username,useraddress,userlon,userlat,usertel,jobname,groupname];
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HMCommonCell *cell = [HMCommonCell cellWithTableView:tableView];
    HMCommonGroup *group = self.groups[indexPath.section];
    cell.item = group.items[indexPath.row];
    // 设置cell所处的行号 和 所处组的总行数
    [cell setIndexPath:indexPath rowsInSection:(int)group.items.count];
    if (indexPath.row == 0) {
        cell.accessoryView = nil;
    }
    return cell;
}

@end
