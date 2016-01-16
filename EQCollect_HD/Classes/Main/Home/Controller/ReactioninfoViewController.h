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
/**
 *  新增人物反应成功后回调
 */
-(void)addReactioninfoSuccess:(ReactioninfoViewController *)reactioninfoVC;

/**
 *  更新人物反应成功后回调
 */
-(void)updateReactioninfoSuccess:(ReactioninfoViewController *)reactioninfoVC;

@end

//////////////////////////////////////////////////////////////////////////////

@interface ReactioninfoViewController : SheetViewController

@property (assign,nonatomic)ActionType actionType;             //操作类型

@property (copy,nonatomic)NSString *pointid;                   //调查点pointid,新增人物反应时需要传过来

@property (strong,nonatomic)ReactionModel *reactioninfo;       //选中的人物反应信息，显示和编辑时需要传过来

@property (weak,nonatomic)id<ReactioninfoDelegate>delegate;

@end
