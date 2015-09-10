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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *abnormalinfoCellId = @"abnormalinfoCell";
    AbnormalinfoCell *cell = [tableView dequeueReusableCellWithIdentifier:abnormalinfoCellId];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AbnormalinfoCell" owner:nil options:nil] lastObject];
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
    if (!self.abnormalinfoVC) {
        self.abnormalinfoVC = [[AbnormalinfoViewController alloc] initWithNibName:@"AbnormalinfoViewController" bundle:nil];
    }
    [self.nav pushViewController:self.abnormalinfoVC animated:YES];
}

@end
