//
//  damageinfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetViewController.h"
@class DamageinfoViewController;
@protocol DamageinfoDelegate <NSObject>
-(void)addDamageinfoSuccess:(DamageinfoViewController *)damageinfoVC;
-(void)updateDamageinfoSuccess:(DamageinfoViewController *)damageinfoVC;
@end

@interface DamageinfoViewController : SheetViewController

@property (assign,nonatomic)ActionType actionType;             //操作类型
@property (copy,nonatomic)NSString *pointid;                 //调查点pointid,新增人物反应时使用;
@property (strong,nonatomic)DamageModel *damageinfo;           //选中的房屋震害信息

@property (weak,nonatomic)id<DamageinfoDelegate>delegate;

@end
