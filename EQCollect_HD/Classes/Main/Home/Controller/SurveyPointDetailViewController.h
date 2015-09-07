//
//  SurveyPointDetailViewController.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QCSlideSwitchView.h"

@interface SurveyPointDetailViewController : UIViewController<QCSlideSwitchViewDelegate>
@property (strong,nonatomic)QCSlideSwitchView *slideSwitchView;
@property (strong,nonatomic)NSMutableArray *vcArray;            //存放控制器的数组
@end
