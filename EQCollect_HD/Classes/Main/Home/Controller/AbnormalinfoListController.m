//
//  AbnormalinfoListController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "AbnormalinfoListController.h"
#import "AbnormalinfoViewController.h"
#import "AbnormalinfoCell.h"

@interface AbnormalinfoListController ()

@end

@implementation AbnormalinfoListController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //下拉刷新
    [self.tableView addHeaderWithTarget:self action:@selector(rereshing)];

    self.tableView.backgroundColor = HMGlobalBg;
    self.tableView.tableFooterView = [[UIView alloc] init];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getDataProvider];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAbnormalinfo:) name:kAddAbnormalinfoSucceedNotification object:nil];
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
    self.dataProvider = [[AbnormalinfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:self.pointid];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *abnormalinfoCellId = @"abnormalinfoCell";
    AbnormalinfoCell *cell = [tableView dequeueReusableCellWithIdentifier:abnormalinfoCellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AbnormalinfoCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //获取Cell的数据
    __block AbnormalinfoModel * abnormalInfo = [self.dataProvider objectAtIndex:indexPath.row];
    
    //设置cell的属性
    cell.abnormalTitleText.text = [NSString stringWithFormat:@"NO.%@",abnormalInfo.abnormalid];
    cell.abnormaltimeText.text = abnormalInfo.abnormaltime;
    cell.intensityText.text = abnormalInfo.abnormalintensity;
    cell.analysisText.text = abnormalInfo.abnormalanalysis;
    cell.crediblyText.text = abnormalInfo.credibly;
    //设置cell的block属性
    cell.deleteAbnormalinfoBlock = ^{
        //从数据库表中删除这个宏观异常信息
       __block BOOL result = YES;
        result = [[PictureInfoTableHelper sharedInstance] deletePictureFromDocumentDirectoryByReleteTable:@"ABNORMALINFOTAB" Releteid:abnormalInfo.abnormalid];
        if (result) {
          result = [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"ABNORMALINFOTAB" Releteid:abnormalInfo.abnormalid];
          if (result) {
            result = [[AbnormalinfoTableHelper sharedInstance] deleteDataByAttribute:@"abnormalid" value:abnormalInfo.abnormalid];
           }
        }
        if (result) {
            //删除成功，则重新获取数据并刷新界面
            [self getDataProvider];
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
    if (!self.abnormalinfoVC) {
        self.abnormalinfoVC = [[AbnormalinfoViewController alloc] initWithNibName:@"AbnormalinfoViewController" bundle:nil];
    }
    self.abnormalinfoVC.abnormalinfo = self.dataProvider[indexPath.row];
    self.abnormalinfoVC.actionType = kActionTypeShow;
    [self.nav pushViewController:self.abnormalinfoVC animated:YES];
}


-(void)updateAbnormalinfo:(NSNotification *)notification
{
    [self.tableView headerBeginRefreshing];
}

@end
