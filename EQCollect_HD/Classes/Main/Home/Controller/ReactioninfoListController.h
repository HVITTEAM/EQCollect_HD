//
//  ReactioninfoListController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReactioninfoViewController.h"

@interface ReactioninfoListController : UITableViewController<ReactioninfoDelegate>

@property (copy,nonatomic)NSString *pointid;                     //对应调查点的 id

@property (copy,nonatomic)NSString *pointUploadFlag;             //对应调查点的上传状态

@end
