//
//  ReactioninfoListController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactioninfoCell.h"
@class ReactioninfoViewController;

@interface ReactioninfoListController : UITableViewController<InfoCellDelegate>
@property (strong,nonatomic)UINavigationController *nav;
@property (strong,nonatomic) ReactioninfoViewController *reactionVC;

@property (nonatomic, retain) NSMutableArray *dataProvider;
@property (copy,nonatomic)NSString *pointid;
@end
