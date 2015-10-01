//
//  ReactioninfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SheetViewController.h"
@interface ReactioninfoViewController : SheetViewController<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionidTopCons;        //人物反应编号TextField的顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionidWidthCons;     //人物反应编号TextField宽约束
@property (strong,nonatomic) NSLayoutConstraint *imgViewHeightCons;  //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;  //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;         //包裹真正内容的容器view

@property (weak, nonatomic) IBOutlet UITextField *reactionidTextF;                //人物反应编号
@property (weak, nonatomic) IBOutlet UITextField *reactiontimeTextF;              //调查时间
@property (weak, nonatomic) IBOutlet UITextField *informantnameTextF;             //被调查者姓名
@property (weak, nonatomic) IBOutlet UITextField *informantageTextF;              //被调查者年龄
@property (weak, nonatomic) IBOutlet UITextField *informanteducationTextF;        //被调查者学历
@property (weak, nonatomic) IBOutlet UITextField *informantjobTextF;              //被调查者职业
@property (weak, nonatomic) IBOutlet UITextField *reactionaddressTextF;           //所在地
@property (weak, nonatomic) IBOutlet UITextField *rockfeelingTextF;               //晃动感觉
@property (weak, nonatomic) IBOutlet UITextField *throwfeelingTextF;              //抛起感觉
@property (weak, nonatomic) IBOutlet UITextField *throwtingsTextF;                //抛弃物
@property (weak, nonatomic) IBOutlet UITextField *throwdistanceTextF;             //抛起距离
@property (weak, nonatomic) IBOutlet UITextField *fallTextF;                      //搁置物滚落
@property (weak, nonatomic) IBOutlet UITextField *hangTextF;                      //悬挂物
@property (weak, nonatomic) IBOutlet UITextField *furnituresoundTextF;            //家具声响
@property (weak, nonatomic) IBOutlet UITextField *furnituredumpTextF;             //家具倾倒
@property (weak, nonatomic) IBOutlet UITextField *soundsizeTextF;                 //地声大小
@property (weak, nonatomic) IBOutlet UITextField *sounddirectionTextF;            //地声方向

@property (assign,nonatomic)ActionType actionType;             //操作类型
@property (copy,nonatomic)NSString *pointid;                 //调查点pointid,新增人物反应时使用;
@property (strong,nonatomic)ReactionModel *reactioninfo;       //选中的人物反应信息

@property (strong,nonatomic)NSArray *textInputViews;           //所有的文本输入框
@property (strong,nonatomic)NSArray *educationItems;           //学历选项
@property (strong,nonatomic)NSArray *rockfeelingItems;         //晃动感觉选项
@property (strong,nonatomic)NSArray *throwfeelingItems;        //抛起感觉选项
@property (strong,nonatomic)NSArray *throwtingsItems;          //抛弃物选项
@property (strong,nonatomic)NSArray *fallItems;                //搁置物滚落选项
@property (strong,nonatomic)NSArray *hangItems;                //悬挂物选项
@property (strong,nonatomic)NSArray *furnituresoundItems;      //家具声响选项
@property (strong,nonatomic)NSArray *soundsizeItems;           //地声大小选项
@property (strong,nonatomic)NSArray *sounddirectionItems;      //地声方向选项
@end
