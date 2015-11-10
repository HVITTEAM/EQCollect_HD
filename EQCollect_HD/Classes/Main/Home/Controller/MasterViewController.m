//
//
//  Created by 董徐维 on 15/8/12.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "MasterViewController.h"
#import "AdminTableHead.h"
#import "LocationHelper.h"

@interface MasterViewController ()
{
    LocationHelper *_locationHelp;
}
@property (nonatomic, retain) SettingViewController *settingView;
@property (nonatomic, retain) PersonCenterController *personView;
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
    //headView.useridLabel.text = [NSString stringWithFormat:@"%ld",(long)[SharedAppUtil defaultCommonUtil].userInfor.userid];
    //headView.usernameLabel.text = [SharedAppUtil defaultCommonUtil].userInfor.username;
    
    //为了截图
    headView.useridLabel.text = @"12345";
    headView.usernameLabel.text = @"admin";
    
    self.tableView.tableHeaderView = headView;
    
    //设置导航栏颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:102/255.0 green:147/255.0 blue:255/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //开启定时发送位置信息功能
    AppDelegate *appdl = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appdl addTimer];
    _locationHelp = [[LocationHelper alloc] init];
    [_locationHelp uploadUserinfo];

}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor colorWithRed:236/255.0f green:240/255.0f blue:241/255.0f alpha:1.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section ==0) {
        cell.textLabel.text = @"个人中心";
        cell.imageView.image = [UIImage imageNamed:@"personCenter"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else if (indexPath.section ==1){
        cell.textLabel.text = @"调查点管理";
        cell.imageView.image = [UIImage imageNamed:@"surveyPoints"];
    }else{
        cell.textLabel.text = @"系统设置";
        cell.imageView.image = [UIImage imageNamed:@"settingIcon"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        PersonCenterController *personView = [[PersonCenterController alloc] init];
        UINavigationController  *nav = [[UINavigationController alloc] initWithRootViewController:personView];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];

    }
    else if (indexPath.section == 2)
    {
        SettingViewController *settingView = [[SettingViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:settingView];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
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
