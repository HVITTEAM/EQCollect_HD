//
//  SheetViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/10/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureVO.h"
#import "PictureMode.h"

@interface SheetViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate,MBProgressHUDDelegate>

@property (weak, nonatomic) UIScrollView *rootScrollV;  //用于滚动的scrollView;

@property (weak, nonatomic) UIView *containerV;         //包裹真正内容的容器view

@property (assign,nonatomic) NSUInteger currentInputViewTag;  //当前文本框的tag

/**
 * 显示提示图标
 **/
-(void)showMBProgressHUDWithSel:(SEL)method;

/**
 * 创建唯一标识号
 **/
-(NSString *)createUniqueIdWithAbbreTableName:(NSString *)name;

/**
 * 保存图片
 **/
-(void)saveImages:(NSArray *)images releteId:(NSString *)releteID releteTable:(NSString *)releteTable;

/**
 * 获取图片
 **/
-(NSMutableArray *)getImagesWithReleteId:(NSString *)releteID releteTable:(NSString *)releteTable;

/**
 *  判断是否有文本框为空
 */
-(BOOL)hasTextBeNullInTextInputViews:(NSArray *)textInputViews;

@end
