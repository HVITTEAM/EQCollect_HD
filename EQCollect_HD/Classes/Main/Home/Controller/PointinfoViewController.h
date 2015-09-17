//
//  PointinfoViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import "CommonUIImagePickerController.h"
#import "PictureMode.h"
#import "PictureVO.h"
#import "PictureInfoTableHelper.h"
#import "ImageCollectionView.h"


@interface PointinfoViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MWPhotoBrowserDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointidTopCons;        //调查点编号TextField的顶部约束
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

@property (assign,nonatomic) BOOL isAdd;                       //是否是新增页面
@property (strong,nonatomic)NSArray *textInputViews;
@property (strong,nonatomic)PointModel *pointinfo;             //选中的调查点信息

//旋转屏幕时更改约束
-(void)rotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@property (strong, nonatomic) IBOutlet UIScrollView *imageBgview;
@property (strong, nonatomic) IBOutlet UIButton *getImgBtn;
- (IBAction)getImgBtnClickHandler:(id)sender;

@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@end
