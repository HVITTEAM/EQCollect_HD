//
//
//  Created by 董徐维 on 15/8/12.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "DetailViewController.h"
//#import "MasterViewController.h"
#import "SurveyPointDetailViewController.h"
#import "PointinfoViewController.h"
#import "SurveyPointCell.h"

@interface DetailViewController ()<UISplitViewControllerDelegate,UISearchBarDelegate,InfoCellDelegate>
@property (nonatomic, retain) SurveyPointDetailViewController *detailview;
//@property (nonatomic, retain) UINavigationController *nav;
@property (nonatomic, retain) PointinfoViewController *pointinfoVC;
@property (nonatomic, retain) NSMutableArray *dataProvider;        //所有的调查点信息
@property (nonatomic, retain) NSArray *filtedData;        //需要显示的调查点信息

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavgation];
    
    self.title = @"调查点管理";
    
    self.tableView.backgroundColor = HMGlobalBg;
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reflesh)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getDataProvider];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointinfo:) name:kAddPointinfoSucceedNotification object:nil];
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    self.detailview = nil;
//}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initNavgation
{
    //设置导航栏颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:102/255.0 green:147/255.0 blue:255/255.0 alpha:1.0];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"新增" style:UIBarButtonItemStylePlain target:self action:@selector(addSurveyPointClickHandler)];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    //搜索框
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder = @"搜索";
    searchBar.delegate = self;
    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = searchBar;
}

#pragma mark 集成刷新控件

/**
 *  集成刷新控件
 */
-(void)reflesh
{
    [self getDataProvider];
    [self.tableView.header endRefreshing];
}

/**
 *  获取数据
 */
-(void)getDataProvider
{
    self.dataProvider = [[PointinfoTableHelper sharedInstance] selectData];
    self.filtedData = self.dataProvider;
    [self.tableView reloadData];
}

/**
 *  新增调查点成功后调用
 */
-(void)updatePointinfo:(NSNotification *)notification
{
    [self.tableView.header beginRefreshing];
}

#pragma mark 分割控制器代理方法
#pragma mark 控制左边的目录（masterViewController）是否隐藏
- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}

#pragma mark 即将显示某个控制器（masterViewController）
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}

#pragma mark 即将隐藏某个控制器（masterViewController）
- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"菜单";
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filtedData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellstr = @"cell";
    SurveyPointCell *cell = [tableView dequeueReusableCellWithIdentifier:cellstr];
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle]loadNibNamed:@"SurveyPointCell" owner:nil options:nil];
        cell = [nibs lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //根据indexPath获取cell的数据
    PointModel * pointInfo = [self.filtedData objectAtIndex:indexPath.row];
    //设置cell的属性
    cell.pointTitleText.text =[NSString stringWithFormat:@"NO.%@",pointInfo.pointid];
    cell.pointTimeText.text = pointInfo.pointtime;
    cell.pointAddressText.text = pointInfo.pointlocation;
    
    if ([pointInfo.upload isEqualToString:@"1"]) {
        cell.uploadBtn.selected = YES;
        [cell.uploadBtn setTitle:@"已上传" forState:UIControlStateNormal];
        [cell.uploadBtn setBackgroundColor:HMColor(0, 160, 70)];
    }else{
        cell.uploadBtn.selected = NO;
        [cell.uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
        [cell.uploadBtn setBackgroundColor:HMColor(102, 147, 255)];
    }
    
    cell.indexPath = indexPath;
    cell.delegate = self;

    return  cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.detailview)
        self.detailview = [[SurveyPointDetailViewController alloc] init];
    self.detailview.pointinfo = self.filtedData[indexPath.row];
    [self.navigationController pushViewController:self.detailview animated:YES];
    
//    SurveyPointDetailViewController *detailview = [[SurveyPointDetailViewController alloc] init];
//    detailview.pointinfo = self.filtedData[indexPath.row];
//    [self.navigationController pushViewController:detailview animated:YES];
}

#pragma mark UISearchBar delegate
/**
 *  UISearchBar的协议方法。根据用户输入的字符串来查找相应的内容。
 */
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length == 0 || searchText == nil) {
        self.filtedData = self.dataProvider;
    }else{
         //使用谓词来过虑，只要调查点信息中有一个属性包含用户输入的字符串，这个调查点就会显示。
        NSPredicate* pred = [NSPredicate predicateWithFormat:@"SELF.pointid CONTAINS[c]%@  OR  SELF.earthid CONTAINS[c]%@  OR  SELF.pointlocation CONTAINS[c]%@  OR  SELF.pointlon CONTAINS[c]%@  OR  SELF.pointlat CONTAINS[c]%@  OR  SELF.pointname CONTAINS[c]%@  OR  SELF.pointtime CONTAINS[c]%@  OR  SELF.pointgroup CONTAINS[c]%@  OR  SELF.pointintensity CONTAINS[c]%@  OR  SELF.pointcontent CONTAINS[c]%@" ,searchText, searchText, searchText, searchText, searchText, searchText, searchText, searchText, searchText, searchText];
        
        self.filtedData = [self.dataProvider filteredArrayUsingPredicate:pred];
    }
    [self.tableView reloadData];
}

#pragma mark addView

-(void)addSurveyPointClickHandler
{
    if (!self.pointinfoVC) {
        self.pointinfoVC = [[PointinfoViewController alloc] init];
    }
    self.pointinfoVC.actionType = kActionTypeAdd;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.pointinfoVC];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - InfoCellDelegate
//删除cell
-(void)infoCell:(InfoCell *)cell didClickDeleteBtnAtIndexPath:(NSIndexPath *)indexPath
{
    //根据indexPath获取cell的数据
    PointModel * pointInfo = [self.filtedData objectAtIndex:indexPath.row];
    
    BOOL result = YES;
    /**从数据库表中删除数据**/
    //删除宏观异常信息
    NSMutableArray *abnor = [[AbnormalinfoTableHelper sharedInstance]selectDataByAttribute:@"pointid" value:pointInfo.pointid];
    for (int i = 0; i<abnor.count; i++) {
        AbnormalinfoModel *abnorModel = abnor[i];
        result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"ABNORMALINFOTAB" Releteid:abnorModel.abnormalid];
        if (result) {
            result =[[AbnormalinfoTableHelper sharedInstance] deleteDataByAttribute:@"abnormalid" value:abnorModel.abnormalid];
        }
    }
    
    //删除人物反应数据
    NSMutableArray *react = [[ReactioninfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:pointInfo.pointid];
    for (int i = 0; i<react.count; i++) {
        ReactionModel *reactModel = react[i];
        result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"REACTIONINFOTAB" Releteid:reactModel.reactionid];
        if (result) {
            result = [[ReactioninfoTableHelper sharedInstance] deleteDataByAttribute:@"reactionid" value:reactModel.reactionid];
        }
    }
    
    //删除房屋震害数据
    NSMutableArray *damage = [[DamageinfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:pointInfo.pointid];
    for (int i = 0; i<damage.count; i++) {
        DamageModel *damageModel = damage[i];
        result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"DAMAGEINFOTAB" Releteid:damageModel.damageid];
        if (result) {
            result = [[DamageinfoTableHelper sharedInstance] deleteDataByAttribute:@"damageid" value:damageModel.damageid];
        }
    }
    
    //删除调查点数据
    if (result) {
        result = [[PointinfoTableHelper sharedInstance] deleteDataByAttribute:@"pointid" value:pointInfo.pointid];
    }
    
    if (result) {
        //数据库中删除成功，则重新获取数据刷新界面
        [self.dataProvider removeObject:pointInfo];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"删除数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }

}

//上传数据
-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath
{
    PointModel *pointInfo = [self.filtedData objectAtIndex:indexPath.row];
    //上传数据 。。。。
    //上传数据成功则更新本地数据
    BOOL result = [[PointinfoTableHelper sharedInstance]updateUploadFlag:@"1" ID:pointInfo.pointid];
    if (result) {
        pointInfo.upload = @"1";
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

@end
