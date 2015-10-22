//
//  PointinfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetViewController.h"

@interface PointinfoViewController : SheetViewController
@property (assign,nonatomic)ActionType actionType;             //操作类型
@property (strong,nonatomic)PointModel *pointinfo;             //选中的调查点信息
//旋转屏幕时更改约束
-(void)rotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
//更新当前界面数据
-(void)updatePointinfo;
@end
