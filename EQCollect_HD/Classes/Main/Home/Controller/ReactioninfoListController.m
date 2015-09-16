//
//  ReactioninfoListController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "ReactioninfoListController.h"
#import "ReactioninfoViewController.h"
#import "ReactioninfoCell.h"

@interface ReactioninfoListController ()

@end

@implementation ReactioninfoListController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    __block ReactionModel * reactioninfo = [self.dataProvider objectAtIndex:indexPath.row];
    //设置cell的属性
    cell.reactionTittle.text = [NSString stringWithFormat:@"NO.%lu  %@",indexPath.row,reactioninfo.reactionid];
    cell.reactiontime.text = reactioninfo.reactiontime;
    cell.reactionaddress.text = reactioninfo.reactionaddress;
    cell.informantname.text = reactioninfo.informantname;
    cell.informantage.text = reactioninfo.informantage;
    cell.informanteducation.text = reactioninfo.informanteducation;
    //设置cell的block属性
    cell.deleteReactioninfoBlock = ^{
        //从数据库表中删除这个人物反应信息
        BOOL result = [[ReactioninfoTableHelper sharedInstance] deleteDataByReactionid:reactioninfo.reactionid];
        if (result) {
            //删除成功，则把这个数据从dataProvider数组中删除并刷新
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
    if (!self.reactionVC) {
       self.reactionVC = [[ReactioninfoViewController alloc]initWithNibName:@"ReactioninfoViewController" bundle:nil];
    }
    self.reactionVC.reactioninfo = self.dataProvider[indexPath.row];
    [self.nav pushViewController:self.reactionVC animated:YES];
}

-(void)updateReactioninfo:(NSNotification *)notification
{
    [self getDataProvider];
}

@end

