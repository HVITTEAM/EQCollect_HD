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
/**
 *  新增房屋震害成功后回调
 */
-(void)addDamageinfoSuccess:(DamageinfoViewController *)damageinfoVC;

/**
 *  更新房屋震害成功后回调
 */
-(void)updateDamageinfoSuccess:(DamageinfoViewController *)damageinfoVC;

@end

////////////////////////////////////////////////////////////////////////////////////////

@interface DamageinfoViewController : SheetViewController

@property (assign,nonatomic)ActionType actionType;             //操作类型

@property (copy,nonatomic)NSString *pointid;                   //调查点pointid,新增房屋震害时需要传过来

@property (strong,nonatomic)DamageModel *damageinfo;           //选中的房屋震害信息，显示和编辑时需要传过来

@property (weak,nonatomic)id<DamageinfoDelegate>delegate;

@end
