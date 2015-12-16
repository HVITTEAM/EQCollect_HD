//
//  OtherViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/12/10.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetViewController.h"
@class OtherModel;
@class OtherViewController;

@protocol OtherinfoDelegate <NSObject>
-(void)addOtherInfoSuccess:(OtherViewController *)otherVC;
-(void)updateOtherInfoSuccess:(OtherViewController *)otherVC;
@end

@interface OtherViewController : SheetViewController
@property (assign,nonatomic)ActionType actionType;             //操作类型
@property (copy,nonatomic)NSString *pointid;                 //调查点pointid,新增人物反应时使用;
@property (strong,nonatomic)OtherModel *otherInfor;           //选中的其它信息对象

@property (weak,nonatomic)id<OtherinfoDelegate>delegate;

@end


