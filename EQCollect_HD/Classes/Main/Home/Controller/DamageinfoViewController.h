//
//  damageinfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DamageinfoViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;                 //底层的ScrollView用于滚动
@property (weak, nonatomic) IBOutlet UIView *containerView;                        //容器view

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopCons;         //容器view的顶部约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerLeftCons;        //容器view的左边约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerWidthCons;       //容器view的宽约束(相对于参照view)
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *damageidWidthCons;        //房屋震害编号TextField宽约束

@property (weak, nonatomic) IBOutlet UITextField *damageidTextF;                   //房屋震害编号
@property (weak, nonatomic) IBOutlet UITextField *damagetimeTextF;                 //调查时间
@property (weak, nonatomic) IBOutlet UITextField *damageaddressTextF;              //地址
@property (weak, nonatomic) IBOutlet UITextField *damageintensityTextF;            //烈度
@property (weak, nonatomic) IBOutlet UITextField *zrcorxqTextF;                    //自然村或小区
@property (weak, nonatomic) IBOutlet UITextField *dworzhTextF;                     //单位或住户
@property (weak, nonatomic) IBOutlet UITextField *fortificationintensityTextF;     //设防烈度
@property (weak, nonatomic) IBOutlet UITextField *damagesituationTextF;            //破坏情况
@property (weak, nonatomic) IBOutlet UITextField *damageindexTextF;                //震害指数

@property (assign,nonatomic) BOOL isAdd;                       //是否是新增页面

@property (strong,nonatomic)NSArray *textInputViews; 

@end
