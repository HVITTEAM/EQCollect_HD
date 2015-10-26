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

@interface AbnormalinfoViewController ()<UIAlertViewDelegate>
{
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
    UIBarButtonItem *_rigthItem;      //导航栏右侧按钮
    ImageCollectionView *imgview;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *abnormalidTopCons;        //宏观异常编号TextField顶部约束
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *abnormalidWidthCons;      //宏观异常编号TextField宽约束
@property (strong,nonatomic)NSLayoutConstraint *imgViewHeightCons;  //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;  //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;         //包裹真正内容的容器view

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

@property (strong,nonatomic)NSArray *textInputViews;           //所有的文本输入框
@property (strong,nonatomic)NSArray *intensityItems;           //烈度选项
@property (strong,nonatomic)NSArray *groundwaterItems;         //地下水选项
@property (strong,nonatomic)NSArray *habitItems;               //动植物习性选项
@property (strong,nonatomic)NSArray *phenomenonItems;          //物化现象选项
@property (strong,nonatomic)NSArray *crediblyItems;            //可信度选项

@end

@implementation AbnormalinfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;

    [self initAbnormalinfoVC];
    [self initImageCollectionView];
    [self showAbnormalinfoData];
}

/**
 *  初始化宏观异常信息控制器
 */
-(void)initAbnormalinfoVC
{
    self.navigationItem.title = @"宏观异常";
    
    //默认有状态栏，高度为64
    _navHeight = kNormalNavHeight;
    _rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemTap:)];
    
    if (![self.abnormalinfo.upload isEqualToString:@"1"]) {
        self.navigationItem.rightBarButtonItem = _rigthItem;
    }
    
    if (self.actionType == kActionTypeAdd){
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        _rigthItem.title = @"确定";
        
        //当为新增时没有状态栏，高度为44
        _navHeight = kAddNavheight;
    }
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
    
    self.intensityItems = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    self.groundwaterItems = @[@"地下水1",@"地下水2",@"地下水3",@"地下水4"];
    self.habitItems = @[@"习性1",@"习性2",@"习性3",@"习性4"];
    self.phenomenonItems = @[@"物化1",@"物化2",@"物化3",@"物化4",@"物化5"];
    self.crediblyItems = @[@"1",@"2",@"3",@"4",@"5"];
    
    //设置顶部高约束
    self.abnormalidTopCons.constant = 20+_navHeight;
    
    [self setActionType:self.actionType];
}

/**
 *  初始化ImageCollectionView
 */
-(void)initImageCollectionView
{
    //创建图片视图
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc]init];
    imgview = [[ImageCollectionView alloc] initWithCollectionViewLayout:flowLayout];
    
    imgview.showType = self.actionType;
    imgview.nav = self.navigationController;
    
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

/**
 *  显示数据
 */
-(void)showAbnormalinfoData
{
    if (self.actionType == kActionTypeShow  || self.actionType == kactionTypeEdit) {
        self.abnormalidTextF.text = self.abnormalinfo.abnormalid;
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
        
        //[self getimage];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *images = [self getImagesWithReleteId:self.abnormalinfo.abnormalid releteTable:@"ABNORMALINFOTAB"];
            dispatch_async(dispatch_get_main_queue(), ^{
                imgview.dataProvider = images;
            });
        });

    }else {
        
        self.abnormalidTextF.text = [self createUniqueIdWithAbbreTableName:@"HG"];
        
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

#pragma mark UITextFieldDelegate方法
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [super textFieldShouldBeginEditing:textField];
    BOOL canEdit;
    //根据文本框的tag来确定哪些允许手动输入，哪些需要弹出框来选择
    switch (textField.tag) {
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
        case 1010:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.crediblyItems];
            break;
        default:
            canEdit = YES;
            break;
    }
    return canEdit;
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
    UITextField *inputView = (UITextField *)[self.view viewWithTag:self.currentInputViewTag];
    //将选中的按钮标题设为当前文本框的内容
    NSString *itemStr = [alertView buttonTitleAtIndex:buttonIndex];
    inputView.text = itemStr;
}

/**
 *  导航栏右侧按钮点击调用
 */
-(void)rightItemTap:(UIBarButtonItem *)sender
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        self.navigationItem.rightBarButtonItem.title = @"确定";
        self.actionType = kactionTypeEdit;
    }else{
        if (self.actionType == kActionTypeAdd) {
            if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
            [self showMBProgressHUDWithSel:@selector(addAbnormalinfo)];
            }
        }else{
            if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
                self.navigationItem.rightBarButtonItem.title = @"编辑";
                [self showMBProgressHUDWithSel:@selector(updateAbnormalinfo)];
                [self.view endEditing:YES];
                self.actionType = kActionTypeShow;
            }
        }
    }
}

/**
 * 新增宏观异常
 **/
-(void)addAbnormalinfo
{
    NSString *abnormalid = self.abnormalidTextF.text;
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
    
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          abnormalid,@"abnormalid",
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        
        //[self saveImagesWithReleteId:abnormalid releteTable:@"ABNORMALINFOTAB"];
        [self saveImages:imgview.dataProvider releteId:abnormalid releteTable:@"ABNORMALINFOTAB"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.view endEditing:YES];
            //清空imageCollectionView的数据
            imgview.dataProvider = [[NSMutableArray alloc] init];
            //防止循环引用导致无法释放当前这个控制器
            imgview.nav = nil;
            if ([self.delegate respondsToSelector:@selector(addAbnormalinfoSuccess:)]) {
                [self.delegate addAbnormalinfoSuccess:self];
            }
        });
    }
}

/**
 * 更新宏观异常
 **/
-(void)updateAbnormalinfo
{
    //NSString *abnormalid = self.abnormalidTextF.text;
    //NSString *abnormaltime = self.abnormaltimeTextF.text;
    NSString *informant = self.informantTextF.text;
    NSString *abnormalintensity = self.abnormalintensityTextF.text;
    NSString *groundwater = self.groundwaterTextF.text;
    NSString *abnormalhabit = self.abnormalhabitTextF.text;
    NSString *abnormalphenomenon = self.abnormalphenomenonTextF.text;
    NSString *other = self.otherTextF.text;
    NSString *implementation = self.implementationTextF.text;
    NSString *abnormalanalysis = self.abnormalanalysisTextF.text;
    NSString *credibly = self.crediblyTextF.text;

    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.abnormalinfo.abnormalid,@"abnormalid",
                          self.abnormalinfo.abnormaltime,@"abnormaltime",
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
                          self.abnormalinfo.upload,@"upload",
                          nil];
    
    BOOL result = [[AbnormalinfoTableHelper sharedInstance] updateDataWith:dict];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"ABNORMALINFOTAB" Releteid:self.abnormalinfo.abnormalid];
        //[self saveImagesWithReleteId:self.abnormalinfo.abnormalid releteTable:@"ABNORMALINFOTAB"];
        [self saveImages:imgview.dataProvider releteId:self.abnormalinfo.abnormalid releteTable:@"ABNORMALINFOTAB"];
        if ([self.delegate respondsToSelector:@selector(updateAbnormalinfoSuccess:)]) {
            [self.delegate updateAbnormalinfoSuccess:self];
        }
    }
}

-(void)back
{
    //清空imageCollectionView的数据
    imgview.dataProvider = [[NSMutableArray alloc] init];
    //防止循环引用导致无法释放当前这个控制器
    imgview.nav = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc
{
    NSLog(@"AbnormalinfoViewController 释放了吗");
}
@end
