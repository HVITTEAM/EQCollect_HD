//
//  PointinfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetViewController.h"

@class PointinfoViewController;

@protocol PointinfoDelegate <NSObject>
/**
 *  新增调查点成功后回调
 */
-(void)addPointinfoSuccess:(PointinfoViewController *)pointinfoVC;

/**
 *  更新调查点成功后回调
 */
-(void)updatePointinfoSuccess:(PointinfoViewController *)pointinfoVC;

@end

////////////////////////////////////////////////////////////////////////////////

@interface PointinfoViewController : SheetViewController

@property (assign,nonatomic)ActionType actionType;             //操作类型

@property (strong,nonatomic)PointModel *pointinfo;             //选中的调查点信息

@property (weak , nonatomic)id<PointinfoDelegate>delegate;

/**
 *  更新当前界面数据
 */
-(void)updatePointinfo;

@end
