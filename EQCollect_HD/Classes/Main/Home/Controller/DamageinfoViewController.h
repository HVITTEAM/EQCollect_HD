//
//  damageinfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetViewController.h"
@interface DamageinfoViewController : SheetViewController<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *damageidTopCons;         //房屋震害编号TextField顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *damageidWidthCons;        //房屋震害编号TextField宽约束
@property (strong,nonatomic)NSLayoutConstraint *imgViewHeightCons;  //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;  //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;         //包裹真正内容的容器view

@property (weak, nonatomic) IBOutlet UITextField *damageidTextF;                   //房屋震害编号
@property (weak, nonatomic) IBOutlet UITextField *damagetimeTextF;                 //调查时间
@property (weak, nonatomic) IBOutlet UITextField *damageaddressTextF;              //地址
@property (weak, nonatomic) IBOutlet UITextField *damageintensityTextF;            //烈度
@property (weak, nonatomic) IBOutlet UITextField *zrcorxqTextF;                    //自然村或小区
@property (weak, nonatomic) IBOutlet UITextField *dworzhTextF;                     //单位或住户
@property (weak, nonatomic) IBOutlet UITextField *fortificationintensityTextF;     //设防烈度
@property (weak, nonatomic) IBOutlet UITextField *damagesituationTextF;            //破坏情况
@property (weak, nonatomic) IBOutlet UITextField *damageindexTextF;                //震害指数

@property (assign,nonatomic)ActionType actionType;             //操作类型
@property (copy,nonatomic)NSString *pointid;                 //调查点pointid,新增人物反应时使用;
@property (strong,nonatomic)DamageModel *damageinfo;           //选中的房屋震害信息

@property (strong,nonatomic)NSArray *textInputViews;                //所有的文本输入框
@property (strong,nonatomic)NSArray *intensityItems;                //烈度选项
@property (strong,nonatomic)NSArray *fortificationintensityItems;   //设防烈度选项
@property (strong,nonatomic)NSArray *damagesituationItems;          //破坏情况选项
@property (strong,nonatomic)NSArray *damageindexItems;              //震害指数选项

@end
