//
//  ReactioninfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetViewController.h"
@class ReactioninfoViewController;
@protocol ReactioninfoDelegate <NSObject>
-(void)addReactioninfoSuccess:(ReactioninfoViewController *)reactioninfoVC;
-(void)updateReactioninfoSuccess:(ReactioninfoViewController *)reactioninfoVC;
@end

@interface ReactioninfoViewController : SheetViewController
@property (assign,nonatomic)ActionType actionType;             //操作类型
@property (copy,nonatomic)NSString *pointid;                 //调查点pointid,新增人物反应时使用;
@property (strong,nonatomic)ReactionModel *reactioninfo;       //选中的人物反应信息

@property (weak,nonatomic)id<ReactioninfoDelegate>delegate;
@end
