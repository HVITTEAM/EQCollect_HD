//
//  DamageinfoListController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DamageinfoViewController;

@interface DamageinfoListController : UITableViewController

@property (strong,nonatomic)UINavigationController *nav;
@property (strong,nonatomic)DamageinfoViewController *damageinfoVC;

@property (nonatomic, retain) NSMutableArray *dataProvider;
@property (copy,nonatomic)NSString *pointid;
@end
