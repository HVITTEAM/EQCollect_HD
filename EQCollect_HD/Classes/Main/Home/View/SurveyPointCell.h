//
//  SurveyPointCell.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoCell.h"

@interface SurveyPointCell : InfoCell<UIAlertViewDelegate>

@property (strong,nonatomic)PointModel *model;

@end

