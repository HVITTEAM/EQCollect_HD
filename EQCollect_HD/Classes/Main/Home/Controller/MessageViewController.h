//
//  MessageViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/11/14.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PointModel;

@interface MessageViewController : UIViewController

@property(nonatomic,strong)PointModel *pointModel;              //这条提示信息对应的调查点信息(必须需传入)

@end

