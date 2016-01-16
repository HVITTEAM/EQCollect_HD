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

@property (copy,nonatomic)NSString *pointid;                   //对应调查点的 id

@property (copy,nonatomic)NSString *pointUploadFlag;           //对应调查点的上传状态

@end
