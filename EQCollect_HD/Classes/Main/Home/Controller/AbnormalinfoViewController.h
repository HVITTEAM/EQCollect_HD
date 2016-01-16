//
//  AbnormalinfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetViewController.h"

@class AbnormalinfoViewController;

@protocol AbnormalinfoDelegate <NSObject>
/**
 *  新增宏观异常成功后回调
 */
-(void)addAbnormalinfoSuccess:(AbnormalinfoViewController *)abnormalinfoVC;

/**
 *  更新宏观异常成功后回调
 */
-(void)updateAbnormalinfoSuccess:(AbnormalinfoViewController *)abnormalinfoVC;

@end

///////////////////////////////////////////////////////////////////////////////////

@interface AbnormalinfoViewController : SheetViewController

@property (assign,nonatomic)ActionType actionType;             //操作类型

@property (copy,nonatomic)NSString *pointid;                   //调查点id,新增宏观异常时传递过来;

@property (strong,nonatomic)AbnormalinfoModel *abnormalinfo;   //选中的宏观异常信息,显示和编辑宏观异常信息时传递过来

@property (weak , nonatomic)id<AbnormalinfoDelegate>delegate;

@end
