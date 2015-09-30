//
//  AbnormalinfoViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
#define kNormalNavHeight 64
#define kAddNavheight 44

#import "AbnormalinfoViewController.h"
#import "ImageCollectionView.h"
#import "PictureMode.h"

@interface AbnormalinfoViewController ()
{
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
    NSUInteger _currentInputViewTag;  //当前文本框的tag
    NSNotification *_currentKeyboardNotification;   //保存键盘通知对象，键盘隐藏时为nil
    NSInteger _lastDistance;                        //键盘遮挡文本时前一次向上移动的距离
}
@end

@implementation AbnormalinfoViewController
{
    ImageCollectionView *imgview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initAbnormalinfoVC];
    [self initImageCollectionView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showAbnormalinfoData];
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //获取图片数据
    if (imgview.showType==kActionTypeShow) {
        [self getimage];
    }
    
    imgview.nav = self.navigationController;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //取消监听键盘事件
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 *  初始化宏观异常信息控制器
 */
-(void)initAbnormalinfoVC
{
    self.navigationItem.title = @"宏观异常";
    
    //默认有状态栏，高度为64
    _navHeight = kNormalNavHeight;
    UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemTap:)];
    self.navigationItem.rightBarButtonItem = rigthItem;
    
    if (self.actionType == kActionTypeAdd){
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        rigthItem.title = @"确定";
        
        //当为新增时没有状态栏，高度为44
        _navHeight = kAddNavheight;
    }
    //获取设备当前方向
    UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
    //将UIDeviceOrientation类型转为UIInterfaceOrientation
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)devOrientation;
    //根据屏幕方向设置视图的约束
    [self rotationToInterfaceOrientation:interfaceOrientation];
    
    self.textInputViews = @[
                            self.abnormalidTextF,
                            self.abnormaltimeTextF,
                            self.informantTextF,
                            self.abnormalintensityTextF,
                            self.groundwaterTextF,
                            self.abnormalhabitTextF,
                            self.abnormalphenomenonTextF,
                            self.otherTextF,
                            self.implementationTextF,
                            self.abnormalanalysisTextF,
                            self.crediblyTextF
                            ];
    for (int i = 0;i<self.textInputViews.count;i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }
    
    self.intensityItems = @[@"强",@"中等",@"弱"];
    self.groundwaterItems = @[@"地下水1",@"地下水2",@"地下水3",@"地下水4"];
    self.habitItems = @[@"习性1",@"习性2",@"习性3",@"习性4"];
    self.phenomenonItems = @[@"物化1",@"物化2",@"物化3",@"物化4",@"物化5"];
    
    [self setActionType:self.actionType];
}

-(void)initImageCollectionView
{
    //创建图片视图
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc]init];
    imgview = [[ImageCollectionView alloc] initWithCollectionViewLayout:flowLayout];
    imgview.nav = self.navigationController;
    imgview.showType = self.actionType;
    [self addChildViewController:imgview];
    [self.containerView addSubview:imgview.collectionView];
    
    //设置 block，当图片数发生变化时会回调
    __weak typeof(self) weakSelf = self;
    __weak ImageCollectionView * weakImgview = imgview;
    imgview.changeHeightBlock = ^(CGFloat viewheight){
         weakSelf.imgViewHeightCons.constant = viewheight;
        [weakImgview.collectionView updateConstraintsIfNeeded];
     };
    
    //设置图片视图约束
    imgview.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *dictViews = @{
                                @"crediblyTextF":self.crediblyTextF,
                                @"imgview":imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[crediblyTextF]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    self.imgViewHeightCons = [NSLayoutConstraint constraintWithItem:imgview.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:87];
    [imgview.collectionView addConstraint:self.imgViewHeightCons];
}

-(void)showAbnormalinfoData
{
    if (self.actionType == kActionTypeShow  || self.actionType == kactionTypeEdit) {
        self.abnormaltimeTextF.text = self.abnormalinfo.abnormaltime;
        self.informantTextF.text = self.abnormalinfo.informant;
        self.abnormalintensityTextF.text = self.abnormalinfo.abnormalintensity;
        self.groundwaterTextF.text = self.abnormalinfo.groundwater;
        self.abnormalhabitTextF.text = self.abnormalinfo.abnormalhabit;
        self.abnormalphenomenonTextF.text = self.abnormalinfo.abnormalphenomenon;
        self.otherTextF.text = self.abnormalinfo.other;
        self.implementationTextF.text = self.abnormalinfo.implementation;
        self.abnormalanalysisTextF.text = self.abnormalinfo.abnormalanalysis;
        self.crediblyTextF.text = self.abnormalinfo.credibly;
        
    }else {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        self.abnormaltimeTextF.text = [formatter stringFromDate:date];
    }
}

/**
 *  ActionType属性的 setter 方法
 */
-(void)setActionType:(ActionType)actionType
{
     _actionType = actionType;
    
     //根据当前选择设置文本框能否编辑
    if (actionType == kActionTypeShow) {
        for (UITextField *txt in self.textInputViews) {
            txt.userInteractionEnabled = NO;
        }
    }else{
        for (UITextField *txt in self.textInputViews) {
            txt.userInteractionEnabled = YES;
        }
    }
    imgview.showType = actionType;
}

//处理屏幕旋转
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self rotationToInterfaceOrientation:interfaceOrientation];
}

/**
 *  旋转屏幕时更改约束
 *
 *  @param interfaceOrientation 要旋转的方向
 */
-(void)rotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)&&self.actionType == kActionTypeShow)
    {
        //设备为横屏且不是新增界面，设置为横屏约束
        self.abnormalidWidthCons.constant = 180;
    }else{
        //设备为竖屏或新增界面，设置为竖屏约束
        self.abnormalidWidthCons.constant = 100;
    }
    self.abnormalidTopCons.constant = 20+_navHeight;
    //更新约束
    [self.view updateConstraintsIfNeeded];
}

#pragma mark UITextFieldDelegate方法
//开始编辑输入框的时候，软键盘出现，执行此事件
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //如果为空，则表是当前键盘隐藏，系统会发出键盘通知
    if (_currentKeyboardNotification !=nil) {
        [self keyboardWillShow:_currentKeyboardNotification];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyNext) {
        _currentInputViewTag +=1;
        //根据tag获取下一个文本框
        UITextField *textF =(UITextField *)[self.view viewWithTag:_currentInputViewTag];
        [textF becomeFirstResponder];
    }
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL canEdit;
    _currentInputViewTag = textField.tag;
    
    //根据文本框的tag来确定哪些允许手动输入，哪些需要弹出框来选择
    switch (_currentInputViewTag) {
        case 1001:
            canEdit = NO;
            break;
        case 1003:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.intensityItems];
            break;
        case 1004:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.groundwaterItems];
            break;
        case 1005:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.habitItems];
            break;
        case 1006:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.phenomenonItems];
            break;
        default:
            canEdit = YES;
            break;
    }
    return canEdit;
}

-(void)addAbnormalinfo
{

    //NSString *abnormalid = self.abnormalidTextF.text;
    NSString *abnormaltime = self.abnormaltimeTextF.text;
    NSString *informant = self.informantTextF.text;
    NSString *abnormalintensity = self.abnormalintensityTextF.text;
    NSString *groundwater = self.groundwaterTextF.text;
    NSString *abnormalhabit = self.abnormalhabitTextF.text;
    NSString *abnormalphenomenon = self.abnormalphenomenonTextF.text;
    NSString *other = self.otherTextF.text;
    NSString *implementation = self.implementationTextF.text;
    NSString *abnormalanalysis = self.abnormalanalysisTextF.text;
    NSString *credibly = self.crediblyTextF.text;
    
    //判断文本输入框是否为空，如果为空则提示并返回
    for (int i=0; i<self.textInputViews.count; i++) {
        UITextField *textF = (UITextField *)self.textInputViews[i];
        if (textF.text ==nil || textF.text.length <= 0) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"所填项目不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            return;
        }
    }
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          //abnormalid,@"abnormalid",
                          abnormaltime,@"abnormaltime",
                          informant,@"informant",
                          abnormalintensity, @"abnormalintensity",
                          groundwater, @"groundwater",
                          abnormalhabit,@"abnormalhabit",
                          abnormalphenomenon,@"abnormalphenomenon",
                          other,@"other",
                          implementation,@"implementation",
                          abnormalanalysis,@"abnormalanalysis",
                          credibly,@"credibly",
                          self.pointid,@"pointid",
                          @"0",@"upload",
                          nil];
    
    BOOL result = [[AbnormalinfoTableHelper sharedInstance] insertDataWith:dict];
    if (!result) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{
        [self setTextinputViewsNil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddAbnormalinfoSucceedNotification object:nil];
        NSInteger maxid=[[AbnormalinfoTableHelper sharedInstance] getMaxIdOfRecords];
        if (maxid!=0 ) {
            [self saveImagesWithReleteId:[NSString stringWithFormat:@"%ld",(long)maxid] releteTable:@"ABNORMALINFOTAB"];
        }
    }
    //清空imageCollectionView的数据
    imgview.dataProvider = [[NSMutableArray alloc] init];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)back
{
    [self setTextinputViewsNil];
    imgview.dataProvider = [[NSMutableArray alloc] init];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  使用UIAlertView向文本框输入内容
 *
 *  @param textField 需要输入内容的文本框
 *  @param items     选项数组
 */
-(void)showAlertViewWithTextField:(UITextField *)textField items:(NSArray *)items
{
    [self.view endEditing:YES];
    //创建UIAlertView并设置标题
    NSString *titleStr = [NSString stringWithFormat:@"%@选项",textField.placeholder];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:titleStr message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    //添加AlertView控件上的按钮
    for (NSString *buttonTitle in items) {
        [alert addButtonWithTitle:buttonTitle];
    }
    //显示AlertView控件
    [alert show];
}

#pragma mark UIAlertViewDelegate方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *inputView = (UITextField *)[self.view viewWithTag:_currentInputViewTag];
    //将选中的按钮标题设为当前文本框的内容
    NSString *itemStr = [alertView buttonTitleAtIndex:buttonIndex];
    inputView.text = itemStr;
}

/**
 *  键盘处理方法，键盘将出现时调用
 */
-(void)keyboardWillShow:(NSNotification *)notification
{
    
    _currentKeyboardNotification = notification;
    UIWindow *keyWin = [[UIApplication sharedApplication] keyWindow];
    //获取键盘属性字典
    NSDictionary *keyboardDict = [notification userInfo];
    //获取键盘y值
    CGRect keyboardFrame = [[keyboardDict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardY = keyWin.frame.size.height - keyboardFrame.size.height;
    //获取键盘动画时间
    CGFloat duration = [[keyboardDict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    //获取动画曲线
    NSInteger curve = [[keyboardDict objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    //获取当前文本框中window中的最大Y值
    UITextField *currentTextField = (UITextField *)[self.view viewWithTag:_currentInputViewTag];
    CGRect frameInWindow = [keyWin convertRect:currentTextField.frame fromView:self.containerView];
    CGFloat currentTextFieldMaxY = CGRectGetMaxY(frameInWindow)+_lastDistance;  //加_lastDistance消除偏移
    
    //当键盘被遮挡时view上移
    if (currentTextFieldMaxY > keyboardY-60) {
         self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0, currentTextFieldMaxY - keyboardY+60, 0);
        [UIView animateKeyframesWithDuration:duration delay:0 options:curve animations:^{
            self.rootScrollView.contentOffset= CGPointMake(0, currentTextFieldMaxY - keyboardY+60);
        } completion:nil];
        //将向上移距离赋值给_lastDistance
        _lastDistance = currentTextFieldMaxY - keyboardY+60;
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
        self.rootScrollView.contentOffset = CGPointMake(0, 0);
    } completion:nil];
    self.rootScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    _currentKeyboardNotification = nil;
    _lastDistance = 0;
}


/**
 * 保存图片
 **/
-(void)saveImagesWithReleteId:(NSString *)releteID releteTable:(NSString *)releteTable
{
    //保存图片
    for (int i = 0; i < imgview.dataProvider.count ; i++)
    {
        if ([imgview.dataProvider[i] isKindOfClass:[PictureVO class]])
        {
            PictureVO *v = (PictureVO*)imgview.dataProvider[i];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", v.name]];
            BOOL result = [UIImagePNGRepresentation(v.image)writeToFile: filePath    atomically:YES];  // 写入本地沙盒
            if (result)
            {
                NSLog(@"success to writeFile");
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      v.name,@"pictureName",
                                      filePath,@"picturePath",
                                      releteID,@"releteid",
                                      releteTable,@"reletetable",
                                      nil];
                NSLog(@"%@",filePath);
                //保存数据库
                [[PictureInfoTableHelper sharedInstance] insertDataWith:dict];
            }
        }
    }
}


/**
 * 获取图片
 **/
-(void)getimage
{
    NSMutableArray *dataProvider = [[NSMutableArray alloc] init];
    NSMutableArray * imageArr= [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:@"ABNORMALINFOTAB" Releteid:self.abnormalinfo.abnormalid];
    //循环添加图片
    for(PictureMode* pic in imageArr)
    {
        PictureVO *vo = [[PictureVO alloc] init];
        vo.name = pic.pictureName;
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", pic.pictureName]];
        UIImage *img = [UIImage imageWithContentsOfFile:filePath];
        vo.image = img;
        [dataProvider addObject:vo];
    }
    imgview.dataProvider = dataProvider;
}

-(void)rightItemTap:(UIBarButtonItem *)sender
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        self.actionType = kactionTypeEdit;
        self.navigationItem.rightBarButtonItem.title = @"确定";
    }else{
        if (self.actionType == kActionTypeAdd) {
            [self addAbnormalinfo];
        }else{
            [self updateAbnormalinfo];
            [self.view endEditing:YES];
            self.actionType = kActionTypeShow;
            self.navigationItem.rightBarButtonItem.title = @"编辑";
        }
    }
}

-(void)updateAbnormalinfo
{
    //NSString *abnormalid = self.abnormalidTextF.text;
    NSString *abnormaltime = self.abnormaltimeTextF.text;
    NSString *informant = self.informantTextF.text;
    NSString *abnormalintensity = self.abnormalintensityTextF.text;
    NSString *groundwater = self.groundwaterTextF.text;
    NSString *abnormalhabit = self.abnormalhabitTextF.text;
    NSString *abnormalphenomenon = self.abnormalphenomenonTextF.text;
    NSString *other = self.otherTextF.text;
    NSString *implementation = self.implementationTextF.text;
    NSString *abnormalanalysis = self.abnormalanalysisTextF.text;
    NSString *credibly = self.crediblyTextF.text;
    
    //判断文本输入框是否为空，如果为空则提示并返回
    for (int i=0; i<self.textInputViews.count; i++) {
        UITextField *textF = (UITextField *)self.textInputViews[i];
        if (textF.text ==nil || textF.text.length <= 0) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"所填项目不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            return;
        }
    }
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.abnormalinfo.abnormalid,@"abnormalid",
                          abnormaltime,@"abnormaltime",
                          informant,@"informant",
                          abnormalintensity, @"abnormalintensity",
                          groundwater, @"groundwater",
                          abnormalhabit,@"abnormalhabit",
                          abnormalphenomenon,@"abnormalphenomenon",
                          other,@"other",
                          implementation,@"implementation",
                          abnormalanalysis,@"abnormalanalysis",
                          credibly,@"credibly",
                          self.abnormalinfo.pointid,@"pointid",
                          @"0",@"upload",
                          nil];
    
    BOOL result = [[AbnormalinfoTableHelper sharedInstance] updateDataWith:dict];
    if (!result) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错,请确定编号唯一" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{
        [self.view endEditing:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddAbnormalinfoSucceedNotification object:nil];
        
        for (id vo in imgview.dataProvider)
        {
            if ([vo isKindOfClass:[PictureVO class]]){
                [[PictureInfoTableHelper sharedInstance] deleteDataByAttribute:@"pictureName" value:((PictureVO *)vo).name];
            }
        }
        [self saveImagesWithReleteId:self.abnormalinfo.abnormalid releteTable:@"ABNORMALINFOTAB"];

    }
}


-(void)setTextinputViewsNil
{
    //self.abnormalidTextF.text = nil;
    self.abnormaltimeTextF.text = nil;
    self.informantTextF.text = nil;
    self.abnormalintensityTextF.text = nil;
    self.groundwaterTextF.text = nil;
    self.abnormalhabitTextF.text = nil;
    self.abnormalphenomenonTextF.text = nil;
    self.otherTextF.text = nil;
    self.implementationTextF.text = nil;
    self.abnormalanalysisTextF.text = nil;
    self.crediblyTextF.text =nil;
}
@end
