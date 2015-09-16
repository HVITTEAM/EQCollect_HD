//
//  AbnormalinfoListController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AbnormalinfoViewController;

@interface AbnormalinfoListController : UITableViewController
@property (strong,nonatomic)UINavigationController *nav;
@property (strong,nonatomic)AbnormalinfoViewController *abnormalinfoVC;

@property (nonatomic, retain) NSMutableArray *dataProvider;
@property (copy,nonatomic)NSString *pointid;

@end
