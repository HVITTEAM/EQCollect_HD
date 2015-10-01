//
//  AbnormalinfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetViewController.h"

@interface AbnormalinfoViewController : SheetViewController<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *abnormalidTopCons;        //宏观异常编号TextField顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *abnormalidWidthCons;      //宏观异常编号TextField宽约束
@property (strong,nonatomic)NSLayoutConstraint *imgViewHeightCons;  //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;  //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;         //包裹真正内容的容器view

@property (weak, nonatomic) IBOutlet UITextField *abnormalidTextF;                 //宏观异常编号
@property (weak, nonatomic) IBOutlet UITextField *abnormaltimeTextF;               //调查时间
@property (weak, nonatomic) IBOutlet UITextField *informantTextF;                  //被调查者
@property (weak, nonatomic) IBOutlet UITextField *abnormalintensityTextF;          //烈度
@property (weak, nonatomic) IBOutlet UITextField *groundwaterTextF;                //地下水
@property (weak, nonatomic) IBOutlet UITextField *abnormalhabitTextF;              //动植物习性
@property (weak, nonatomic) IBOutlet UITextField *abnormalphenomenonTextF;         //物化现象
@property (weak, nonatomic) IBOutlet UITextField *otherTextF;                      //其他
@property (weak, nonatomic) IBOutlet UITextField *implementationTextF;             //落实情况
@property (weak, nonatomic) IBOutlet UITextField *abnormalanalysisTextF;           //初步分析
@property (weak, nonatomic) IBOutlet UITextField *crediblyTextF;                   //可信度

@property (assign,nonatomic)ActionType actionType;             //操作类型
@property (copy,nonatomic)NSString *pointid;                   //调查点id,新增宏观异常时传递过来;
@property (strong,nonatomic)AbnormalinfoModel *abnormalinfo;   //显示和编辑宏观异常信息时传递过来

@property (strong,nonatomic)NSArray *textInputViews;           //所有的文本输入框
@property (strong,nonatomic)NSArray *intensityItems;           //烈度选项
@property (strong,nonatomic)NSArray *groundwaterItems;         //地下水选项
@property (strong,nonatomic)NSArray *habitItems;               //动植物习性选项
@property (strong,nonatomic)NSArray *phenomenonItems;          //物化现象选项

@end
