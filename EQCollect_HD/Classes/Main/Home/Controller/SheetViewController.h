//
//  SheetViewController.h
//  EQCollect_HD
//
//  Created by shi on 15/10/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SheetViewController : UIViewController<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) UIScrollView *rootScrollV;  //用于滚动的scrollView;
@property (weak, nonatomic) UIView *containerV;         //包裹真正内容的容器view
@property (assign,nonatomic) NSUInteger currentInputViewTag;  //当前文本框的tag

//-(void)keyboardWillShow:(NSNotification *)notification;
//-(void)keyboardWillHide:(NSNotification *)notification;
@end
