//
//  ReactioninfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReactioninfoViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;                //底层的ScrollView用于滚动
@property (weak, nonatomic) IBOutlet UIView *containerView;                        //容器view

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerLeftCons;       //容器view的左边约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerWidthCons;      //容器view的宽约束(相对于参照view)
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionidWidthCons;     //人物反应编号TextField宽约束

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

@end
