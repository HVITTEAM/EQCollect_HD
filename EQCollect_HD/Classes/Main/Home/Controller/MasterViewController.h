//  
//
//  Created by 董徐维 on 15/8/12.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"
#import "PersonCenterController.h"

@interface MasterViewController : UITableViewController

@property (nonatomic, retain) SettingViewController *settingView;
@property (nonatomic, retain) PersonCenterController *personView;

@property (nonatomic, retain) UINavigationController *nav;
@end
