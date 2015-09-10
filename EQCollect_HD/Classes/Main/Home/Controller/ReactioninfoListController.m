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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reactioninfoCellId = @"reactioninfoCell";
    ReactioninfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reactioninfoCellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReactioninfoCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
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
    [self.nav pushViewController:self.reactionVC animated:YES];
}



@end
