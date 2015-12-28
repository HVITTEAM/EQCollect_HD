//
//  SheetViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/10/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "SheetViewController.h"

@interface SheetViewController ()

@property(strong,nonatomic)NSNotification *currentKeyboardNotification;   //保存键盘通知对象，键盘隐藏时为nil

@property(assign,nonatomic)NSInteger lastDistance;                        //键盘遮挡文本时前一次向上移动的距离

@property(strong,nonatomic)MBProgressHUD *HUD;

@end

@implementation SheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //取消监听键盘事件
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark -- 协议方法 --
#pragma mark UITextFieldDelegate方法
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //如果为空，则表是当前键盘隐藏，系统会发出键盘通知
    if (self.currentKeyboardNotification !=nil) {
        [self keyboardWillShow:_currentKeyboardNotification];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext) {
        self.currentInputViewTag +=1;
        //根据tag获取下一个文本框
        UIView *textF =[self.view viewWithTag:self.currentInputViewTag];
        [textF becomeFirstResponder];
    }
    
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.currentInputViewTag = textField.tag;
    return YES;
}

#pragma mark UITextViewDelegate方法
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    //如果为空，则表是当前键盘隐藏，系统会发出键盘通知
    if (self.currentKeyboardNotification !=nil) {
        [self keyboardWillShow:self.currentKeyboardNotification];
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.currentInputViewTag = textView.tag;
    return YES;
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

#pragma mark -- 事件方法 --
#pragma mark 键盘相关方法
/**
 *  键盘处理方法，键盘将出现时调用
 */
-(void)keyboardWillShow:(NSNotification *)notification
{
    self.currentKeyboardNotification = notification;
    UIWindow *keyWin = [[UIApplication sharedApplication] keyWindow];
    
    //键盘最大 Y 值
    CGFloat keyboardY;
    //当前文本框最大 y 值
    CGFloat currentTextFieldMaxY;
    
    //获取键盘属性字典
    NSDictionary *keyboardDict = [notification userInfo];
    //获取键盘动画时间
    CGFloat duration = [[keyboardDict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //获取动画曲线
    NSInteger curve = [[keyboardDict objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    //获取键盘frame值
    CGRect keyboardFrame = [[keyboardDict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //获取当前文本框在window中的frame
    UITextField *currentTextField = (UITextField *)[self.view viewWithTag:_currentInputViewTag];
    CGRect frameInWindow = [keyWin convertRect:currentTextField.frame fromView:self.containerV];
    
    if (IOS_VERSION < 8.0) {
        UIDeviceOrientation devOrientation = (UIDeviceOrientation)self.interfaceOrientation;
        switch (devOrientation) {
            case UIDeviceOrientationPortrait:
                keyboardY = keyWin.frame.size.height - keyboardFrame.size.height;
                currentTextFieldMaxY = CGRectGetMaxY(frameInWindow);
                break;
            case UIDeviceOrientationLandscapeLeft:
                keyboardY = keyWin.frame.size.width - keyboardFrame.size.width;
                currentTextFieldMaxY = keyWin.frame.size.width - frameInWindow.origin.x;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                keyboardY = keyWin.frame.size.height - keyboardFrame.size.height;
                currentTextFieldMaxY = keyWin.frame.size.height - frameInWindow.origin.y;
                break;
            case UIDeviceOrientationLandscapeRight:
                keyboardY = keyWin.frame.size.width - keyboardFrame.size.width;
                currentTextFieldMaxY = CGRectGetMaxX(frameInWindow);
                break;
            default:
                break;
        }
    }else{
        keyboardY = keyWin.frame.size.height - keyboardFrame.size.height;
        currentTextFieldMaxY = CGRectGetMaxY(frameInWindow);
    }
    
    //加_lastDistance消除偏移
    currentTextFieldMaxY = currentTextFieldMaxY + _lastDistance;
    
    //当键盘被遮挡时view上移
    if (currentTextFieldMaxY > keyboardY-60) {
        self.rootScrollV.contentInset = UIEdgeInsetsMake(0, 0, currentTextFieldMaxY - keyboardY+60, 0);
        [UIView animateKeyframesWithDuration:duration delay:0 options:curve animations:^{
            self.rootScrollV.contentOffset= CGPointMake(0, currentTextFieldMaxY - keyboardY+60);
        } completion:nil];
        //将向上移距离赋值给_lastDistance
        self.lastDistance = currentTextFieldMaxY - keyboardY+60;
    }
}

/**
 *  键盘处理方法，键盘将隐藏时调用
 */
-(void)keyboardWillHide:(NSNotification *)notification
{
    //获取键盘属性字典
    NSDictionary *keyboardDict = [notification userInfo];
    //获取键盘动画时间
    CGFloat duration = [[keyboardDict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //获取动画曲线
    NSInteger curve = [[keyboardDict objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    //复原View属性
    [UIView animateKeyframesWithDuration:duration delay:0 options:curve animations:^{
        self.rootScrollV.contentOffset = CGPointMake(0, 0);
    } completion:nil];
    self.rootScrollV.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.currentKeyboardNotification = nil;
    self.lastDistance = 0;
}

#pragma mark -- 公开方法 --
/**
 * 显示等待动画MBProgressHUD
 **/
-(void)showMBProgressHUDWithSel:(SEL)method
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.HUD = [[MBProgressHUD alloc] initWithWindow:window];
    [window addSubview:self.HUD];
    
    self.HUD.delegate = self;
    self.HUD.labelText = @"请稍等...";
    
    [self.HUD showWhileExecuting:method onTarget:self withObject:nil animated:YES];
}

/**
 * 保存图片
 **/
-(void)saveImages:(NSArray *)images releteId:(NSString *)releteID releteTable:(NSString *)releteTable
{
    //保存图片
    for (int i = 0; i < images.count ; i++)
    {
        if ([images[i] isKindOfClass:[PictureVO class]])
        {
            PictureVO *v = (PictureVO*)images[i];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", v.name]];
            BOOL result = [v.imageData writeToFile: filePath atomically:YES]; // 写入本地沙盒
            if (result)
            {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      v.name,@"pictureName",
                                      filePath,@"picturePath",
                                      releteID,@"releteid",
                                      releteTable,@"reletetable",
                                      nil];
                //保存数据库
                [[PictureInfoTableHelper sharedInstance] insertDataWith:dict];
            }
        }
    }
}

/**
 * 获取图片
 **/
-(NSMutableArray *)getImagesWithReleteId:(NSString *)releteID releteTable:(NSString *)releteTable
{
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSMutableArray * pictureModes= [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:releteTable Releteid:releteID];
    //循环添加图片
    for(PictureMode* pic in pictureModes)
    {
        PictureVO *vo = [[PictureVO alloc] init];
        vo.name = pic.pictureName;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", pic.pictureName]];
        vo.imageData = [NSData dataWithContentsOfFile:filePath];
        [images addObject:vo];
    }
    return images;
}

/**
 *  判断是否有文本框为空
 */
-(BOOL)hasTextBeNullInTextInputViews:(NSArray *)textInputViews
{
    //判断文本输入框是否为空，如果为空则提示并返回
    for (int i=0; i<textInputViews.count; i++) {
        UITextField *textF = (UITextField *)textInputViews[i];
        if (textF.text ==nil || textF.text.length <=0) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"所填项目不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            return YES;
        }
    }
    return NO;
}

/**
 * 创建唯一标识号
 **/
-(NSString *)createUniqueIdWithAbbreTableName:(NSString *)name
{
   NSDate *datenow = [NSDate date];
   NSString *timeSp = [NSString stringWithFormat:@"%@%ld", name,(long)[datenow timeIntervalSince1970]];
   return timeSp;
}

@end
