//
//  OtherListViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/12/10.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OtherViewController.h"

@interface OtherListViewController : UITableViewController<OtherinfoDelegate>

@property (strong,nonatomic)UINavigationController *nav;
@property (copy,nonatomic)NSString *pointid;
@property (copy,nonatomic)NSString *pointUploadFlag;

@end
