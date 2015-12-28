//
//  damageinfoViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#define kNormalNavHeight 64
#define kAddNavheight 44
#import "DamageinfoViewController.h"
#import "ImageCollectionView.h"
#import "PictureMode.h"
#import "ChooseIntensityViewController.h"
#import "CacheUtil.h"

@interface DamageinfoViewController ()<UIAlertViewDelegate,chooseIntensityDelegate>
{
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
    UIBarButtonItem *_rigthItem;      //导航栏右侧按钮
    ImageCollectionView *imgview;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *damageidTopCons;         //房屋震害编号TextField顶部约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;  //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;         //包裹真正内容的容器view

@property (strong,nonatomic)NSLayoutConstraint *imgViewHeightCons;  //图片View的高约束

@property (weak, nonatomic) IBOutlet UITextField *damageidTextF;
@property (weak, nonatomic) IBOutlet UITextField *damagetimeTextF;
@property (weak, nonatomic) IBOutlet UITextField *buildingageTextF;
@property (weak, nonatomic) IBOutlet UITextField *damageareaTextF;
@property (weak, nonatomic) IBOutlet UITextField *fieldtypeTextF;
@property (weak, nonatomic) IBOutlet UITextField *damagelevelTextF;
@property (weak, nonatomic) IBOutlet UITextField *zrcorxqTextF;
@property (weak, nonatomic) IBOutlet UITextField *dworzhTextF;
@property (weak, nonatomic) IBOutlet UITextField *fortificationintensityTextF;
@property (weak, nonatomic) IBOutlet UITextField *damageindexTextF;
@property (weak, nonatomic) IBOutlet UITextField *damagerindexTextF;
@property (weak, nonatomic) IBOutlet UITextField *housetypeTextF;

@property (weak, nonatomic) IBOutlet UITextView *damagesituationTextView;

@property (strong,nonatomic)NSArray *textInputViews;                //所有的文本输入框
@property (strong,nonatomic)NSArray *zrcorxqItems;                  //自然村小区
@property (strong,nonatomic)NSArray *dworzhItems;                   //单位住户
@property (strong,nonatomic)NSArray *damagelevelItems;              //破坏等级
@property (strong,nonatomic)NSArray *fortificationintensityItems;   //设防烈度选项
@property (strong,nonatomic)NSArray *houseTypeItems;                //房屋类型选项

@end

@implementation DamageinfoViewController

#pragma mark -- 生命周期方法 --
- (void)viewDidLoad {
    [super viewDidLoad];
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;

    [self initNavBar];
    [self initDamageinfo];
    [self initImageCollectionView];
    [self showDamageinfoData];
}

#pragma mark -- 初始化方法 --
/**
 *  初始化导航栏
 */
-(void)initNavBar
{
    self.navigationItem.title = @"房屋震害";
    
    //默认有状态栏，高度为64
    _navHeight = kNormalNavHeight;
    
    _rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemTap:)];
    if ([self.damageinfo.upload isEqualToString:kdidNotUpload]) {
        self.navigationItem.rightBarButtonItem = _rigthItem;
    }
    
    if (self.actionType == kActionTypeAdd) {
        //设置导航栏按钮
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        
        _rigthItem.title = @"确定";
        self.navigationItem.rightBarButtonItem = _rigthItem;
        
        //当为新增时没有状态栏，高度为44
        _navHeight = kAddNavheight;
    }
}

/**
 *  初始化房屋震害信息控制器
 */
-(void)initDamageinfo
{
    self.damagesituationTextView.backgroundColor = [UIColor whiteColor];
    self.damagesituationTextView.layer.borderColor = HMColor(210, 210, 210).CGColor;
    self.damagesituationTextView.layer.borderWidth = 0.6f;
    self.damagesituationTextView.layer.cornerRadius = 8.0f;
    
     self.textInputViews = @[
                            self.damageidTextF,
                            self.damagetimeTextF,
                            self.zrcorxqTextF,
                            self.dworzhTextF,
                            self.fortificationintensityTextF,
                            self.damagelevelTextF,
                            self.damageindexTextF,
                            self.damagerindexTextF,
                            self.damageareaTextF,
                            self.housetypeTextF,
                            self.buildingageTextF,
                            self.fieldtypeTextF,
                            self.damagesituationTextView
                             ];
    for (int i = 0;i < self.textInputViews.count - 1;i++) {
        UITextView *textInputView = self.textInputViews[i];
        textInputView.delegate = self;
        textInputView.tag = 1000 + i;
    }
    self.damagesituationTextView.delegate = self;
    self.damagesituationTextView.tag = 1000 + self.textInputViews.count-1;

    self.zrcorxqItems = @[@"自然村",@"小区"];
    self.dworzhItems = @[@"单位",@"住户"];
    self.fortificationintensityItems = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    self.damagelevelItems = @[@"毁坏",@"严重破坏",@"中等破坏",@"轻微破坏",@"基本完好"];
    self.houseTypeItems = @[@"钢混",@"设防砖混",@"砖混",@"砖木",@"土木",@"其它"];
    
    //设置顶部高约束
    self.damageidTopCons.constant = 20+_navHeight;
    
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
    
    //设置 block，当图片行数发生变化时会调用
    __weak typeof(self) weakSelf = self;
    __weak ImageCollectionView * weakImgview = imgview;
    imgview.changeHeightBlock = ^(CGFloat viewheight){
        weakSelf.imgViewHeightCons.constant = viewheight;
        [weakImgview.collectionView updateConstraintsIfNeeded];
    };
    
    //设置视图约束
    imgview.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *dictViews = @{
                                @"damagesituationTextView":self.damagesituationTextView,
                                @"imgview":imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[damagesituationTextView]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    self.imgViewHeightCons = [NSLayoutConstraint constraintWithItem:imgview.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:87];
    [imgview.collectionView addConstraint:self.imgViewHeightCons];
}

/**
 *  显示数据
 */
-(void)showDamageinfoData
{
    if (self.actionType == kActionTypeShow || self.actionType == kactionTypeEdit) {
        self.damageidTextF.text = self.damageinfo.damageid;
        self.damagetimeTextF.text = self.damageinfo.damagetime;
        self.zrcorxqTextF.text = self.damageinfo.zrcorxq;
        self.dworzhTextF.text = self.damageinfo.dworzh;
        self.fortificationintensityTextF.text = self.damageinfo.fortificationintensity;
        self.damagelevelTextF.text = self.damageinfo.damagelevel;
        self.damageindexTextF.text = self.damageinfo.damageindex;
        self.damagerindexTextF.text = self.damageinfo.damagerindex;
        self.damageareaTextF.text = self.damageinfo.damagearea;
        self.housetypeTextF.text = self.damageinfo.housetype;
        self.buildingageTextF.text = self.damageinfo.buildingage;
        self.fieldtypeTextF.text = self.damageinfo.fieldtype;
        self.damagesituationTextView.text = self.damageinfo.damagesituation;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *images = [self getImagesWithReleteId:self.damageinfo.damageid releteTable:@"DAMAGEINFOTAB"];
            dispatch_async(dispatch_get_main_queue(), ^{
                imgview.dataProvider = images;
            });
        });
        
    }else {
        
        self.damageidTextF.text = [self createUniqueIdWithAbbreTableName:@"ZH"];
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        self.damagetimeTextF.text = [formatter stringFromDate:date];
        
        DamageModel *cache = [CacheUtil shareInstance].cacheDamage;
        if (!cache) {
            return;
        }
        self.zrcorxqTextF.text = cache.zrcorxq;
        self.dworzhTextF.text = cache.dworzh;
        self.fortificationintensityTextF.text = cache.fortificationintensity;
        self.damagelevelTextF.text = cache.damagelevel;
        self.damageindexTextF.text = cache.damageindex;
        self.damagerindexTextF.text = cache.damagerindex;
        self.damageareaTextF.text = cache.damagearea;
        self.housetypeTextF.text = cache.housetype;
        self.buildingageTextF.text = cache.buildingage;
        self.fieldtypeTextF.text = cache.fieldtype;
        self.damagesituationTextView.text = cache.damagesituation;
    }
}

#pragma mark -- setter和getter方法 --

/**
 *  ActionType属性的 setter 方法
 */
-(void)setActionType:(ActionType)actionType
{
    _actionType = actionType;
    if (actionType == kActionTypeShow) {
        for (UIView *inputView in self.textInputViews) {
            inputView.userInteractionEnabled = NO;
        }
    }else{
        for (UIView *inputView in self.textInputViews) {
            inputView.userInteractionEnabled = YES;
        }
    }
    imgview.showType = self.actionType;
}

#pragma mark UITextFieldDelegate方法

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [super textFieldShouldBeginEditing:textField];
    BOOL canEdit;
    //根据文本框的tag来确定哪些允许手动输入，哪些需要弹出框来选择
    if (textField.tag == 1000||textField.tag == 1001) {
        canEdit = NO;
    }else if (textField.tag == 1002){
        canEdit = NO;
        [self showAlertViewWithTextField:textField items:self.zrcorxqItems];
    }else if (textField.tag == 1003){
        canEdit = NO;
        [self showAlertViewWithTextField:textField items:self.dworzhItems];
    }else if (textField.tag == 1004){
        canEdit = NO;
        ChooseIntensityViewController *intensityVC = [ChooseIntensityViewController sharedInstance];
        intensityVC.delegate = self;
        UINavigationController *naviga = [[UINavigationController alloc] initWithRootViewController:intensityVC];
        naviga.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:naviga animated:YES completion:nil];
    }else if (textField.tag == 1005){
        canEdit = NO;
        [self showAlertViewWithTextField:textField items:self.damagelevelItems];
    }else if (textField.tag == 1009){
        canEdit = NO;
        [self showAlertViewWithTextField:textField items:self.houseTypeItems];
    }else{
         canEdit = YES;
    }
    return canEdit;
}


-(void)viewController:(ChooseIntensityViewController *)chooseIntensityVC selectedIntensity:(NSString *)intensity
{
    UITextField *textField = (UITextField *)[self.view viewWithTag:self.currentInputViewTag];
    textField.text = intensity;
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
    if (self.actionType == kActionTypeShow) {
        self.navigationItem.rightBarButtonItem.title = @"确定";
        self.actionType = kactionTypeEdit;
    }else if(self.actionType == kActionTypeAdd){
        //判断是否有文本框为空，有空则返回并提示
        if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
            [self showMBProgressHUDWithSel:@selector(addDamageinfo)];
        }
    }else{
        //判断是否有文本框为空，有空则返回并提示
        if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
            
            [self showMBProgressHUDWithSel:@selector(updateDamageinfo)];
            self.actionType = kActionTypeShow;
            //[self.view endEditing:YES];
            self.navigationItem.rightBarButtonItem.title = @"编辑";
        }
    }
}

/**
 *  新增房屋震害
 */
-(void)addDamageinfo
{
    //防止异步加载图片出错
    imgview.isExitThread = YES;
    
    NSString *damageid = self.damageidTextF.text;
    NSString *damagetime = self.damagetimeTextF.text;
    NSString *buildingage = self.buildingageTextF.text;
    NSString *damagearea = self.damageareaTextF.text;
    NSString *fieldtype = self.fieldtypeTextF.text;
    NSString *damagelevel = self.damagelevelTextF.text;
    NSString *zrcorxq = self.zrcorxqTextF.text;
    NSString *dworzh = self.dworzhTextF.text;
    NSString *fortificationintensity = self.fortificationintensityTextF.text;
    NSString *damagesituation = self.damagesituationTextView.text;
    NSString *damageindex = self.damageindexTextF.text;
    NSString *damagerindex = self.damagerindexTextF.text;
    NSString *housetype = self.housetypeTextF.text;

    NSString *pointid = self.pointid;
    NSString *upload = kdidNotUpload;
    
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          damageid,@"damageid",
                          damagetime,@"damagetime",
                          buildingage,@"buildingage",
                          damagearea, @"damagearea",
                          fieldtype, @"fieldtype",
                          damagelevel,@"damagelevel",
                          zrcorxq,@"zrcorxq",
                          dworzh,@"dworzh",
                          fortificationintensity,@"fortificationintensity",
                          damagesituation,@"damagesituation",
                          damageindex,@"damageindex",
                          damagerindex,@"damagerindex",
                          housetype,@"housetype",
                          pointid,@"pointid",
                          upload,@"upload",
                          nil];
    
    [[CacheUtil shareInstance] setCacheDamageWithDict:dict];
    
    BOOL result = [[DamageinfoTableHelper sharedInstance] insertDataWith:dict];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{

        [self saveImages:imgview.dataProvider releteId:damageid releteTable:@"DAMAGEINFOTAB"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.view endEditing:YES];
            //清空imageCollectionView的数据
            imgview.dataProvider = [[NSMutableArray alloc] init];
            //防止循环引用导致无法释放当前这个控制器
            imgview.nav = nil;
            if ([self.delegate respondsToSelector:@selector(addDamageinfoSuccess:)]) {
                [self.delegate addDamageinfoSuccess:self];
            }
        });
    }
}

/**
 * 更新房屋震害
 **/
-(void)updateDamageinfo
{
    //防止异步加载图片出错
    imgview.isExitThread = YES;

    NSString *damageid = self.damageinfo.damageid;
    NSString *damagetime = self.damageinfo.damagetime;
    
    NSString *buildingage = self.buildingageTextF.text;
    NSString *damagearea = self.damageareaTextF.text;
    NSString *fieldtype = self.fieldtypeTextF.text;
    NSString *damagelevel = self.damagelevelTextF.text;
    NSString *zrcorxq = self.zrcorxqTextF.text;
    NSString *dworzh = self.dworzhTextF.text;
    NSString *fortificationintensity = self.fortificationintensityTextF.text;
    NSString *damagesituation = self.damagesituationTextView.text;
    NSString *damageindex = self.damageindexTextF.text;
    NSString *damagerindex = self.damagerindexTextF.text;
    NSString *housetype = self.housetypeTextF.text;
    
    NSString *pointid = self.damageinfo.pointid;
    NSString *upload = self.damageinfo.upload;
    
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          damageid,@"damageid",
                          damagetime,@"damagetime",
                          buildingage,@"buildingage",
                          damagearea, @"damagearea",
                          fieldtype, @"fieldtype",
                          damagelevel,@"damagelevel",
                          zrcorxq,@"zrcorxq",
                          dworzh,@"dworzh",
                          fortificationintensity,@"fortificationintensity",
                          damagesituation,@"damagesituation",
                          damageindex,@"damageindex",
                          damagerindex,@"damagerindex",
                          housetype,@"housetype",
                          pointid,@"pointid",
                          upload,@"upload",
                          nil];
    
    [[CacheUtil shareInstance] setCacheDamageWithDict:dict];

    BOOL result = [[DamageinfoTableHelper sharedInstance] updateDataWith:dict];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"DAMAGEINFOTAB" Releteid:self.damageinfo.damageid];
        [self saveImages:imgview.dataProvider releteId:self.damageinfo.damageid releteTable:@"DAMAGEINFOTAB"];
        
        if ([self.delegate respondsToSelector:@selector(updateDamageinfoSuccess:)]) {
            [self.delegate updateDamageinfoSuccess:self];
        }
    }
}

-(NSString *)switchRomeNumToNum:(NSString *)romeNum
{
    NSArray *romes = @[@"Ⅰ",@"Ⅱ",@"Ⅲ",@"Ⅳ",@"Ⅴ",@"Ⅵ",@"Ⅶ",@"Ⅷ",@"Ⅸ",@"Ⅹ",@"Ⅺ",@"Ⅻ"];
    NSUInteger num = [romes indexOfObject:romeNum];
    return [NSString stringWithFormat:@"%d",(int)(num+1)];
}

-(void)back
{
    //清空imageCollectionView的数据
    imgview.dataProvider = [[NSMutableArray alloc] init];
    //防止循环引用导致无法释放当前这个控制器
    imgview.nav = nil;
    //防止异步加载图片出错
    imgview.isExitThread = YES;

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc
{
    NSLog(@"DamageinfoViewController释放了吗。。。。。。。。。。。。。");
}
@end
