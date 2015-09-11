//  
//
//  Created by 董徐维 on 15/8/12.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingViewController.h"
#import "PersonCenterController.h"
#import "UserModel.h"
#import "AdminTableHead.h"

@interface MasterViewController : UITableViewController
@property (nonatomic, copy) void (^selectedType)(NSDictionary *type);

@property (nonatomic, retain) SettingViewController *settingView;
@property (nonatomic, retain) PersonCenterController *personView;

@property (nonatomic, retain) UINavigationController *nav;

@property (nonatomic,strong) UserModel *usermd;

@end
