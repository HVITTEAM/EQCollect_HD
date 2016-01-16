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
#import "ImageCollectionFlowLayout.h"
#import "ChooseIntensityViewController.h"
#import "CacheUtil.h"

@interface AbnormalinfoViewController ()<UIAlertViewDelegate,chooseIntensityDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *abnormalidTopCons;        //宏观异常编号TextField顶部约束
@property (strong,nonatomic) NSLayoutConstraint *imgViewHeightCons;                 //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;                 //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;                        //包裹真正内容的容器view

@property (assign,nonatomic)CGFloat navHeight;                  // 导航栏与状态栏总的高度
@property (strong,nonatomic)ImageCollectionView *imgview;       //图片展示控件

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

@end

@implementation AbnormalinfoViewController

#pragma mark -- 生命周期方法 --
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;

    [self initNavBar];
    
    [self initAbnormalinfoVC];
    
    [self initImageCollectionView];
    
    [self showAbnormalinfoData];
}

#pragma mark -- 初始化子视图方法 --
/**
 *  初始化导航栏
 */
-(void)initNavBar
{
    //默认有状态栏，高度为64
    self.navHeight = kNormalNavHeight;
    
    self.navigationItem.title = @"宏观异常";
    UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemTap:)];
    //没上传可以编辑,上传了不可编辑
    if ([self.abnormalinfo.upload isEqualToString:kdidNotUpload]) {
        self.navigationItem.rightBarButtonItem = rigthItem;
    }
    
    if (self.actionType == kActionTypeAdd){
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        rigthItem.title = @"确定";
        self.navigationItem.rightBarButtonItem = rigthItem;
        
        //当为新增时没有状态栏，高度为44
        self.navHeight = kAddNavheight;
    }
}

/**
 *  初始化宏观异常信息控制器
 */
-(void)initAbnormalinfoVC
{
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
    
    //设置顶部高约束
    self.abnormalidTopCons.constant = 20 + self.navHeight;
    
    [self setActionType:self.actionType];
}

/**
 *  初始化ImageCollectionView
 */
-(void)initImageCollectionView
{
    //创建图片视图
    ImageCollectionFlowLayout *flowLayout =[[ImageCollectionFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(70, 70);
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.imgview = [[ImageCollectionView alloc] initWithCollectionViewLayout:flowLayout];
    
    self.imgview.showType = self.actionType;
    
    [self addChildViewController:self.imgview];
    [self.containerView addSubview:self.imgview.collectionView];
    
    //设置 block，当图片数发生变化时会回调
    __weak typeof(self) weakSelf = self;
    self.imgview.changeHeightBlock = ^(CGFloat viewheight){
         weakSelf.imgViewHeightCons.constant = viewheight;
        [weakSelf.imgview.collectionView updateConstraintsIfNeeded];
     };
    
    //设置图片视图约束
    self.imgview.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *dictViews = @{
                                @"crediblyTextF":self.crediblyTextF,
                                @"imgview":self.imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[crediblyTextF]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    self.imgViewHeightCons = [NSLayoutConstraint constraintWithItem:self.imgview.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:87];
    [self.imgview.collectionView addConstraint:self.imgViewHeightCons];
}

/**
 *  显示数据
 */
-(void)showAbnormalinfoData
{
    if (self.actionType == kActionTypeShow  || self.actionType == kactionTypeEdit) {         //显示数据
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *images = [self getImagesWithReleteId:self.abnormalinfo.abnormalid releteTable:@"ABNORMALINFOTAB"];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imgview.dataProvider = images;
            });
        });
    }else {             //新增数据
        
        //设置宏观异常编号
        self.abnormalidTextF.text = [self createUniqueIdWithAbbreTableName:@"HG"];
        //设置时间
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        self.abnormaltimeTextF.text = [formatter stringFromDate:date];
        
        //用上一次缓存数据临时显示，减少输入
        AbnormalinfoModel *cache = [CacheUtil shareInstance].cacheAbnormalinfo;
        if (!cache) {
            return;
        }
        self.abnormalidTextF.text = cache.abnormalid;
        self.abnormaltimeTextF.text = cache.abnormaltime;
        self.informantTextF.text = cache.informant;
        self.abnormalintensityTextF.text = cache.abnormalintensity;
        self.groundwaterTextF.text = cache.groundwater;
        self.abnormalhabitTextF.text = cache.abnormalhabit;
        self.abnormalphenomenonTextF.text = cache.abnormalphenomenon;
        self.otherTextF.text = cache.other;
        self.implementationTextF.text = cache.implementation;
        self.abnormalanalysisTextF.text = cache.abnormalanalysis;
        self.crediblyTextF.text = cache.credibly;
    }
}

#pragma mark -- getter 和 setter 方法 --
/**
 *  ActionType属性的 setter 方法
 */
-(void)setActionType:(ActionType)actionType
{
     _actionType = actionType;
     //根据当前选择设置文本框能否编辑
    if (actionType == kActionTypeShow) {
        for (UIView *txt in self.textInputViews) {
            txt.userInteractionEnabled = NO;
        }
    }else{
        for (UIView *txt in self.textInputViews) {
            txt.userInteractionEnabled = YES;
        }
    }
    self.imgview.showType = actionType;
}

#pragma mark -- 协议方法 --
#pragma mark UITextFieldDelegate方法
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [super textFieldShouldBeginEditing:textField];
    BOOL canEdit;
    //根据文本框的tag来确定哪些允许手动输入，哪些需要弹出框来选择
    if (textField.tag == 1000 || textField.tag == 1001) {
        canEdit = NO;
    }else if (textField.tag == 1003){
        canEdit = NO;
        ChooseIntensityViewController *intensityVC = [ChooseIntensityViewController sharedInstance];
        intensityVC.delegate = self;
        UINavigationController *naviga = [[UINavigationController alloc] initWithRootViewController:intensityVC];
        naviga.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:naviga animated:YES completion:nil];
    }else{
        canEdit = YES;
    }
    return canEdit;
}

#pragma mark chooseIntensityDelegate
/**
 *  选中烈度后回调
 */
-(void)viewController:(ChooseIntensityViewController *)chooseIntensityVC selectedIntensity:(NSString *)intensity
{
    self.abnormalintensityTextF.text = intensity;
}

#pragma mark -- 事件方法 --
/**
 *  导航栏右侧按钮点击调用
 */
-(void)rightItemTap:(UIBarButtonItem *)sender
{
    if (self.actionType == kActionTypeShow) {
        self.navigationItem.rightBarButtonItem.title = @"确定";
        self.actionType = kactionTypeEdit;
    }else if(self.actionType == kActionTypeAdd){
        //判断是否有文本框为空，有空则返回并提示
        if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
            [self showMBProgressHUDWithSel:@selector(addAbnormalinfo)];
        }
    }else{    //如果是编辑
        //判断是否有文本框为空，有空则返回并提示
        if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
            [self showMBProgressHUDWithSel:@selector(updateAbnormalinfo)];
            self.actionType = kActionTypeShow;
            self.navigationItem.rightBarButtonItem.title = @"编辑";
        }
    }
}

/**
 * 新增宏观异常
 **/
-(void)addAbnormalinfo
{
    //防止异步加载图片出错
    self.imgview.isExitThread = YES;

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
    
    NSString *pointid = self.pointid;
    NSString *upload = kdidNotUpload;
    
    //创建一个AbnormalinfoModel对象
    AbnormalinfoModel *abnormalModel = [[AbnormalinfoModel alloc] init];
    abnormalModel.abnormalid = abnormalid;
    abnormalModel.abnormaltime = abnormaltime;
    abnormalModel.informant = informant;
    abnormalModel.abnormalintensity = abnormalintensity;
    abnormalModel.groundwater = groundwater;
    abnormalModel.abnormalhabit = abnormalhabit;
    abnormalModel.abnormalphenomenon = abnormalphenomenon;
    abnormalModel.other = other;
    abnormalModel.implementation = implementation;
    abnormalModel.abnormalanalysis = abnormalanalysis;
    abnormalModel.credibly = credibly;
    abnormalModel.pointid = pointid;
    abnormalModel.upload = upload;
    
     //数据缓存起来
    [CacheUtil shareInstance].cacheAbnormalinfo = abnormalModel;
     //本地数据库保存
    BOOL result = [[AbnormalinfoTableHelper sharedInstance] insertDataWithAbnormalinfoModel:abnormalModel];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        //保存图片
        [self saveImages:self.imgview.dataProvider releteId:abnormalid releteTable:@"ABNORMALINFOTAB"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            //清空imageCollectionView的数据
            self.imgview.dataProvider = [[NSMutableArray alloc] init];
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
    //防止异步加载图片出错
    self.imgview.isExitThread = YES;

    NSString *informant = self.informantTextF.text;
    NSString *abnormalintensity = self.abnormalintensityTextF.text;
    NSString *groundwater = self.groundwaterTextF.text;
    NSString *abnormalhabit = self.abnormalhabitTextF.text;
    NSString *abnormalphenomenon = self.abnormalphenomenonTextF.text;
    NSString *other = self.otherTextF.text;
    NSString *implementation = self.implementationTextF.text;
    NSString *abnormalanalysis = self.abnormalanalysisTextF.text;
    NSString *credibly = self.crediblyTextF.text;
    
    NSString *abnormalid = self.abnormalinfo.abnormalid;
    NSString *abnormaltime = self.abnormalinfo.abnormaltime;
    NSString *pointid = self.abnormalinfo.pointid;
    NSString *upload = self.abnormalinfo.upload;

    //创建一个AbnormalinfoModel对象
    AbnormalinfoModel *abnormalModel = [[AbnormalinfoModel alloc] init];
    abnormalModel.abnormalid = abnormalid;
    abnormalModel.abnormaltime = abnormaltime;
    abnormalModel.informant = informant;
    abnormalModel.abnormalintensity = abnormalintensity;
    abnormalModel.groundwater = groundwater;
    abnormalModel.abnormalhabit = abnormalhabit;
    abnormalModel.abnormalphenomenon = abnormalphenomenon;
    abnormalModel.other = other;
    abnormalModel.implementation = implementation;
    abnormalModel.abnormalanalysis = abnormalanalysis;
    abnormalModel.credibly = credibly;
    abnormalModel.pointid = pointid;
    abnormalModel.upload = upload;
    
    //数据缓存起来
    [CacheUtil shareInstance].cacheAbnormalinfo = abnormalModel;

    //本地数据库保存
    BOOL result = [[AbnormalinfoTableHelper sharedInstance] updateDataWithAbnormalinfoModel:abnormalModel];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        //保存图片
        [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"ABNORMALINFOTAB" Releteid:self.abnormalinfo.abnormalid];
        [self saveImages:self.imgview.dataProvider releteId:self.abnormalinfo.abnormalid releteTable:@"ABNORMALINFOTAB"];
        if ([self.delegate respondsToSelector:@selector(updateAbnormalinfoSuccess:)]) {
            [self.delegate updateAbnormalinfoSuccess:self];
        }
    }
}

-(void)back
{
    //清空imageCollectionView的数据
    self.imgview.dataProvider = [[NSMutableArray alloc] init];
    //防止异步加载图片出错
    self.imgview.isExitThread = YES;

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc
{
    NSLog(@"AbnormalinfoViewController 释放了吗");
}

@end
