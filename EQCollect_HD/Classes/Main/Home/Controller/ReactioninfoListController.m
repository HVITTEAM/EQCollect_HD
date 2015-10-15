//
//  ReactioninfoListController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "ReactioninfoListController.h"
#import "ReactioninfoViewController.h"

@interface ReactioninfoListController ()

@end

@implementation ReactioninfoListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //下拉刷新
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(rereshing)];
    
    self.tableView.backgroundColor = HMGlobalBg;
    self.tableView.tableFooterView = [[UIView alloc] init];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getDataProvider];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReactioninfo:) name:kAddReactioninfoSucceedNotification object:nil];
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
    [self.tableView.header endRefreshing];
}

/**
 *  获取数据
 */
-(void)getDataProvider
{
    self.dataProvider = [[ReactioninfoTableHelper sharedInstance] selectDataByAttribute:@"pointid" value:self.pointid];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataProvider.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reactioninfoCellId = @"reactioninfoCell";
    ReactioninfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reactioninfoCellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReactioninfoCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    //获取cell的数据
    ReactionModel * reactioninfo = [self.dataProvider objectAtIndex:indexPath.row];
    //设置cell的属性
    cell.reactionTittle.text = [NSString stringWithFormat:@"NO.%@",reactioninfo.reactionid];
    cell.reactiontime.text = reactioninfo.reactiontime;
    cell.reactionaddress.text = reactioninfo.reactionaddress;
    cell.informantname.text = reactioninfo.informantname;
    cell.informantage.text = reactioninfo.informantage;
    cell.informanteducation.text = reactioninfo.informanteducation;
    
    if ([reactioninfo.upload isEqualToString:@"1"]) {
        cell.uploadBtn.selected = YES;
        [cell.uploadBtn setBackgroundColor:HMColor(0, 160, 70)];
        [cell.uploadBtn setTitle:@"已上传" forState:UIControlStateNormal];
    }else{
        cell.uploadBtn.selected = NO;
        [cell.uploadBtn setBackgroundColor:HMColor(102, 147, 255)];
        [cell.uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
    }
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.reactionVC) {
       self.reactionVC = [[ReactioninfoViewController alloc]initWithNibName:@"ReactioninfoViewController" bundle:nil];
    }
    self.reactionVC.reactioninfo = self.dataProvider[indexPath.row];
    self.reactionVC.actionType = kActionTypeShow;
    [self.nav pushViewController:self.reactionVC animated:YES];
}

-(void)updateReactioninfo:(NSNotification *)notification
{
    [self.tableView.header beginRefreshing];
}

#pragma mark - InfoCellDelegate
//删除cell
-(void)infoCell:(InfoCell *)cell didClickDeleteBtnAtIndexPath:(NSIndexPath *)indexPath
{
    //获取cell的数据
    ReactionModel * reactioninfo = [self.dataProvider objectAtIndex:indexPath.row];
    
    //从数据库表中删除这个人物反应信息
    BOOL result = YES;
    result = [[PictureInfoTableHelper sharedInstance] deleteImageByReleteTable:@"REACTIONINFOTAB" Releteid:reactioninfo.reactionid];
    if (result) {
        result = [[ReactioninfoTableHelper sharedInstance] deleteDataByAttribute:@"reactionid" value:reactioninfo.reactionid];
    }
    if (result) {
        //删除成功，则重新获取数据并刷新
        [self.dataProvider removeObject:reactioninfo];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }else{
        [[[UIAlertView alloc] initWithTitle:nil message:@"删除数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }
}

//上传数据
-(void)infocell:(InfoCell *)cell didClickUpLoadBtnAtIndexPath:(NSIndexPath *)indexPath
{
    ReactionModel *model = [self.dataProvider objectAtIndex:indexPath.row];
    //上传数据 。。。。
    //上传数据成功则更新本地数据
    BOOL result = [[ReactioninfoTableHelper sharedInstance]updateUploadFlag:@"1" ID:model.reactionid];
    if (result) {
        model.upload = @"1";
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

@end

