//
//  SurveyPointDetailViewController.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCSlideSwitchView.h"

@class AbnormalinfoListController,ReactioninfoListController,DamageinfoListController;
@class PointinfoViewController,AbnormalinfoViewController,ReactioninfoViewController,DamageinfoViewController;

@interface SurveyPointDetailViewController : UIViewController<QCSlideSwitchViewDelegate>
@property (strong,nonatomic)QCSlideSwitchView *slideSwitchView;
@property (strong,nonatomic)NSMutableArray *vcArray;            //存放控制器的数组

@property (strong,nonatomic)AbnormalinfoListController *abnormalinfoListVC;
@property (strong,nonatomic)ReactioninfoListController *reactioninfoListVC;
@property (strong,nonatomic)DamageinfoListController   *damageinfoListVC;

@property (strong,nonatomic)PointinfoViewController *pointinfoVC;
@property (strong,nonatomic)AbnormalinfoViewController *abnormalVC;
@property (strong,nonatomic)ReactioninfoViewController *reactionifoVC;
@property (strong,nonatomic)DamageinfoViewController *damageinfoVC;

@property (strong,nonatomic)PointModel *pointinfo;           //选中的调查点信息
@end
