//
//  AbnormalinfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AbnormalinfoViewController : UIViewController<UITextFieldDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *abnormalidTopCons;        //宏观异常编号TextField顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *abnormalidWidthCons;      //宏观异常编号TextField宽约束

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

@property (assign,nonatomic) BOOL isAdd;                       //是否是新增页面
@property (copy,nonatomic)NSString *pointid;
@property (strong,nonatomic)AbnormalinfoModel *abnormalinfo;     //选中的宏观异常信息


@property (strong,nonatomic)NSArray *textInputViews;           //所有的文本输入框
@property (strong,nonatomic)NSArray *intensityItems;           //烈度选项
@property (strong,nonatomic)NSArray *groundwaterItems;         //地下水选项
@property (strong,nonatomic)NSArray *habitItems;               //动植物习性选项
@property (strong,nonatomic)NSArray *phenomenonItems;          //物化现象选项
@end
