//
//
//  Created by 董徐维 on 15/8/12.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "DetailViewController.h"
#import "MasterViewController.h"
#import "SurveyPointCell.h"
#import "SurveyPointDetailViewController.h"
#import "PointinfoViewController.h"

@interface DetailViewController ()
{
    NSArray *_foods;
    
    UISearchDisplayController *searchDisplayController;
    
    SurveyPointDetailViewController *detailview;
    
}
@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavgation];
    
    self.title = @"调查点管理";
    
    self.tableView.backgroundColor = HMGlobalBg;
    
    [self getDataProvider];
    
    //下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(reflesh)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointinfo:) name:kAddPointinfoSucceedNotification object:nil];
}

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
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width
                                                                           , 44)];
    searchBar.placeholder = @"搜索";
    
    // 添加 searchbar 到 headerview
    self.tableView.tableHeaderView = searchBar;
    
    // 用 searchbar 初始化 SearchDisplayController
    // 并把 searchDisplayController 和当前 controller 关联起来
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    
    // searchResultsDataSource 就是 UITableViewDataSource
    searchDisplayController.searchResultsDataSource = self;
    // searchResultsDelegate 就是 UITableViewDelegate
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsTableView.backgroundColor = HMGlobalBg;
}

#pragma mark 集成刷新控件

/**
 *  集成刷新控件
 */
-(void)reflesh
{
    [self getDataProvider];
    [self.tableView headerEndRefreshing];
}

-(void)getDataProvider
{
    self.dataProvider = [[PointinfoTableHelper sharedInstance] selectData];
    [self.tableView reloadData];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
        return self.dataProvider.count;
    else
        return 3;
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
    __block PointModel * pointInfo = [self.dataProvider objectAtIndex:indexPath.row];
    //设置cell的属性
    cell.pointTitleText.text =[NSString stringWithFormat:@"NO.%lu  %@",indexPath.row,pointInfo.pointid];
    cell.pointTimeText.text = pointInfo.pointtime;
    cell.pointAddressText.text = pointInfo.pointlocation;
    //设置cell的deletePointBlock属性，
    cell.deletePointBlock = ^{
        //从数据库表中删除数据
        BOOL result = [[PointinfoTableHelper sharedInstance] deleteDataByPointid:pointInfo.pointid];
        if (result) {
            //数据库中删除成功，则从dataProvider数组中删除数据并刷新界面
            [self.dataProvider removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        }else{
            [[[UIAlertView alloc] initWithTitle:nil message:@"删除数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }
    };
    return  cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!detailview)
        detailview = [[SurveyPointDetailViewController alloc] init];
    detailview.pointinfo = self.dataProvider[indexPath.row];
    [self.navigationController pushViewController:detailview animated:YES];
}

#pragma mark addView
-(void)addSurveyPointClickHandler
{
    if (!self.pointinfoVC) {
        self.pointinfoVC = [[PointinfoViewController alloc] init];
    }
    self.pointinfoVC.isAdd = YES;
    self.nav = [[UINavigationController alloc] initWithRootViewController:self.pointinfoVC];
    self.nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:self.nav animated:YES completion:nil];
}

-(void)updatePointinfo:(NSNotification *)notification
{
    [self.tableView headerBeginRefreshing];
}


@end
