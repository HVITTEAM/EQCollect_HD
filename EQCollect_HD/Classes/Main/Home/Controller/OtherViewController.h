//
//  OtherViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/12/10.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetViewController.h"

@class OtherViewController;

@protocol OtherinfoDelegate <NSObject>
/**
 *  新增其它数据成功后回调
 */
-(void)addOtherInfoSuccess:(OtherViewController *)otherVC;

/**
 *  更新其它数据成功后回调
 */
-(void)updateOtherInfoSuccess:(OtherViewController *)otherVC;

@end

/////////////////////////////////////////////////////////////////////////////////

@interface OtherViewController : SheetViewController

@property (assign,nonatomic)ActionType actionType;             //操作类型

@property (copy,nonatomic)NSString *pointid;                  //调查点pointid,新增其它信息时需要传过来

@property (strong,nonatomic)OtherModel *otherInfor;           //选中的其它信息,显示和编辑时需要传过来

@property (weak,nonatomic)id<OtherinfoDelegate>delegate;

@end


