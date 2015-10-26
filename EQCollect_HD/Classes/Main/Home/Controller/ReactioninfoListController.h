//
//  ReactioninfoListController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactioninfoCell.h"
#import "ReactioninfoViewController.h"

@interface ReactioninfoListController : UITableViewController<InfoCellDelegate,ReactioninfoDelegate>

@property (strong,nonatomic)UINavigationController *nav;
@property (copy,nonatomic)NSString *pointid;
@property (copy,nonatomic)NSString *pointUploadFlag;

@end
