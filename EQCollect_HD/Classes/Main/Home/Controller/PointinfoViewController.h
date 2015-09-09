//
//  PointinfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointinfoViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;                 //底层的ScrollView用于滚动
@property (weak, nonatomic) IBOutlet UIView *containerView;                        //容器view

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerLeftCons;     //容器view的左边约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerWidthCons;    //容器view的宽约束(相对于参照view)
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointidWidthCons;      //调查点编号TextField的宽约束

@property (weak, nonatomic) IBOutlet UITextField *pointidTextF;                 //调查点编号
@property (weak, nonatomic) IBOutlet UITextField *earthidTextF;                 //地震编号
@property (weak, nonatomic) IBOutlet UITextField *pointlocationTextF;           //调查点地点
@property (weak, nonatomic) IBOutlet UITextField *pointlonTextF;                //调查点经度
@property (weak, nonatomic) IBOutlet UITextField *pointlatTextF;                //调查点纬度
@property (weak, nonatomic) IBOutlet UITextField *pointnameTextF;               //调查点名称
@property (weak, nonatomic) IBOutlet UITextField *pointtimeTextF;               //生成时间
@property (weak, nonatomic) IBOutlet UITextField *pointgroupTextF;              //小组名称
@property (weak, nonatomic) IBOutlet UITextField *pointintensityTextF;          //评定烈度
@property (weak, nonatomic) IBOutlet UITextView *pointcontentTextV;             //调查简述

//SurveyPointDetailViewController的根视图
@property (strong,nonatomic)UIView *surveyPointDetailView;

//旋转屏幕时更改约束
-(void)rotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
