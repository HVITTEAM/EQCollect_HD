//
//  DamageinfoListController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "DamageinfoListController.h"
#import "DamageinfoViewController.h"
#import "DamageinfoCell.h"

@interface DamageinfoListController ()

@end

@implementation DamageinfoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    //下拉刷新
    __weak typeof(self) weakSelf = self;
    [self.tableView addHeaderWithCallback:^{
        [weakSelf getDataProvider];
        [weakSelf.tableView headerEndRefreshing];
    }];
    
    self.tableView.backgroundColor = HMGlobalBg;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getDataProvider];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDamageinfo:) name:kAddDamageinfoSucceedNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  刷新数据
 */
-(void)rereshing
{
    [self getDataProvider];
    [self.tableView headerEndRefreshing];
}

/**
 *  获取数据
 */
-(void)getDataProvider
{
    self.dataProvider = [[DamageinfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:self.pointid];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *damageinfoCellId = @"damageinfoCell";
    DamageinfoCell *cell = [tableView dequeueReusableCellWithIdentifier:damageinfoCellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DamageinfoCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //获取cell的数据
    __block DamageModel * damageinfo = [self.dataProvider objectAtIndex:indexPath.row];
    //设置cell的属性
    cell.damageid.text = [NSString stringWithFormat:@"NO.%lu   %@",indexPath.row,damageinfo.damageid];
    cell.damagetime.text = damageinfo.damagetime;
    cell.damageintensity.text = damageinfo.damageintensity;
    cell.damagesituation.text = damageinfo.damagesituation;
    cell.damageaddress.text = damageinfo.damageaddress;
    cell.fortificationintensity.text = damageinfo.fortificationintensity;
    //设置cell的block属性
    cell.deleteDamageinfoBlock = ^{
        //从数据库表中删除房屋震害信息
        BOOL result = [[DamageinfoTableHelper sharedInstance] deleteDataByDamageid:damageinfo.damageid];
        if (result) {
            //如果删除成功，则把房屋震害信息从dataProvider数组中删除并刷新界面
            [self.dataProvider removeObjectAtIndex:indexPath.row];
            [self.tableView reloadData];
        }else{
            [[[UIAlertView alloc] initWithTitle:nil message:@"删除数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        }
    };
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.damageinfoVC) {
        self.damageinfoVC = [[DamageinfoViewController alloc] initWithNibName:@"DamageinfoViewController" bundle:nil];
    }
    self.damageinfoVC.damageinfo = self.dataProvider[indexPath.row];
    [self.nav pushViewController:self.damageinfoVC animated:YES];
}

-(void)updateDamageinfo:(NSNotification *)notification
{
    [self.tableView headerBeginRefreshing];
}

@end