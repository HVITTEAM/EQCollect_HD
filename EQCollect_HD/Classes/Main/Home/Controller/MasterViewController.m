//
//
//  Created by 董徐维 on 15/8/12.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "MasterViewController.h"
#import "SettingViewController.h"
#import "PersonCenterController.h"
#import "AdminTableHead.h"
#import "LocationHelper.h"
#import "EQMapViewController.h"

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"浙江省地震灾害现场采集";
    
    //设置表头视图
    AdminTableHead *headView  = [[[NSBundle mainBundle] loadNibNamed:@"AdminTableHead" owner:self options:nil] lastObject];
    UserModel *userInfor = [ArchiverCacheHelper getLocaldataBykey:User_Archiver_Key filePath:User_Archiver_Path];
    headView.useridLabel.text = userInfor.userccount;
    headView.usernameLabel.text = userInfor.username;
    self.tableView.tableHeaderView = headView;
    
    //设置导航栏颜色
    self.navigationController.navigationBar.barTintColor = HMColor(102, 147, 255);
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //开启定时发送位置信息功能
    AppDelegate *appdl = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdl addTimer];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = HMColor(236, 240, 241);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section ==0) {
        cell.textLabel.text = @"个人中心";
        cell.imageView.image = [UIImage imageNamed:@"personCenter"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.section ==1){
        cell.textLabel.text = @"调查点管理";
        cell.imageView.image = [UIImage imageNamed:@"surveyPoints"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if(indexPath.section == 2){
        cell.textLabel.text = @"系统设置";
        cell.imageView.image = [UIImage imageNamed:@"settingIcon"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.textLabel.text = @"地图";
        cell.imageView.image = [UIImage imageNamed:@"settingIcon"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0){
        PersonCenterController *personView = [[PersonCenterController alloc] init];
        UINavigationController  *nav = [[UINavigationController alloc] initWithRootViewController:personView];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];

    }else if (indexPath.section == 1){
    
    }
    else if (indexPath.section == 2){
        SettingViewController *settingView = [[SettingViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingView];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
    }else if (indexPath.section == 3){
        EQMapViewController *mapVC = [[EQMapViewController alloc] init];
        UIWindow *win =[UIApplication sharedApplication].keyWindow;
        NSArray *VCs = ((UISplitViewController *)win.rootViewController).viewControllers;
        UINavigationController *detailNavi = VCs[1];
        [detailNavi pushViewController:mapVC animated:YES];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    //去除分区脚视图背景颜色
    return [[UIView alloc] init];
}
@end
