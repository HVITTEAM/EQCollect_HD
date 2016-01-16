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
#import "ChooseIntensityViewController.h"
#import "CacheUtil.h"
#import "ImageCollectionFlowLayout.h"

@interface DamageinfoViewController ()<UIAlertViewDelegate,chooseIntensityDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *damageidTopCons;         //房屋震害编号TextField顶部约束
@property (strong,nonatomic)NSLayoutConstraint *imgViewHeightCons;                //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;                //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;                       //包裹真正内容的容器view

@property (assign,nonatomic)CGFloat navHeight;                  // 导航栏与状态栏总的高度
@property (strong,nonatomic)ImageCollectionView *imgview;       //图片展示控件

@property (weak, nonatomic) IBOutlet UITextField *damageidTextF;                   //房屋震害编号
@property (weak, nonatomic) IBOutlet UITextField *damagetimeTextF;                 //调查时间
@property (weak, nonatomic) IBOutlet UITextField *buildingageTextF;                //建造年代
@property (weak, nonatomic) IBOutlet UITextField *damageareaTextF;                 //房屋面积
@property (weak, nonatomic) IBOutlet UITextField *fieldtypeTextF;                  //场地类型
@property (weak, nonatomic) IBOutlet UITextField *damagelevelTextF;                //破坏等级
@property (weak, nonatomic) IBOutlet UITextField *zrcorxqTextF;                    //自然村或小区
@property (weak, nonatomic) IBOutlet UITextField *dworzhTextF;                     //单位或住户
@property (weak, nonatomic) IBOutlet UITextField *fortificationintensityTextF;     //设防烈度
@property (weak, nonatomic) IBOutlet UITextField *damageindexTextF;                //震害指数（自动）
@property (weak, nonatomic) IBOutlet UITextField *damagerindexTextF;               //震害指数（人工）
@property (weak, nonatomic) IBOutlet UITextField *housetypeTextF;                  //房屋类型

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

#pragma mark -- 初始化子视图方法 --
/**
 *  初始化导航栏
 */
-(void)initNavBar
{
    //默认有状态栏，高度为64
    self.navHeight = kNormalNavHeight;
    
    self.navigationItem.title = @"房屋震害";
    UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemTap:)];
    //没上传可以编辑,上传了不可编辑
    if ([self.damageinfo.upload isEqualToString:kdidNotUpload]) {
        self.navigationItem.rightBarButtonItem = rigthItem;
    }
    
    if (self.actionType == kActionTypeAdd) {
        //设置导航栏按钮
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        rigthItem.title = @"确定";
        self.navigationItem.rightBarButtonItem = rigthItem;
        
        //当为新增时没有状态栏，高度为44
        self.navHeight = kAddNavheight;
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
    self.damageidTopCons.constant = 20 + self.navHeight;
    
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
    
    //设置 block，当图片行数发生变化时会调用
    __weak typeof(self) weakSelf = self;
    self.imgview.changeHeightBlock = ^(CGFloat viewheight){
        weakSelf.imgViewHeightCons.constant = viewheight;
        [weakSelf.imgview.collectionView updateConstraintsIfNeeded];
    };
    
    //设置视图约束
    self.imgview.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *dictViews = @{
                                @"damagesituationTextView":self.damagesituationTextView,
                                @"imgview":self.imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[damagesituationTextView]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    self.imgViewHeightCons = [NSLayoutConstraint constraintWithItem:self.imgview.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:87];
    [self.imgview.collectionView addConstraint:self.imgViewHeightCons];
}

/**
 *  显示数据
 */
-(void)showDamageinfoData
{
    if (self.actionType == kActionTypeShow || self.actionType == kactionTypeEdit) {       //显示数据
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
                self.imgview.dataProvider = images;
            });
        });
    }else {    //新增数据
        //设置房屋震害编号
        self.damageidTextF.text = [self createUniqueIdWithAbbreTableName:@"ZH"];
        //设置时间
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        self.damagetimeTextF.text = [formatter stringFromDate:date];
        
        //用上一次缓存数据临时显示，减少输入
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
    self.imgview.showType = self.actionType;
}

#pragma mark -- 协议方法 --
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

#pragma mark UIAlertViewDelegate方法
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *inputView = (UITextField *)[self.view viewWithTag:self.currentInputViewTag];
    //将选中的按钮标题设为当前文本框的内容
    NSString *itemStr = [alertView buttonTitleAtIndex:buttonIndex];
    inputView.text = itemStr;
}

#pragma mark chooseIntensityDelegate
/**
 *  选中烈度后回调
 */
-(void)viewController:(ChooseIntensityViewController *)chooseIntensityVC selectedIntensity:(NSString *)intensity
{
    self.fortificationintensityTextF.text = intensity;
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
            [self showMBProgressHUDWithSel:@selector(addDamageinfo)];
        }
    }else{
        //判断是否有文本框为空，有空则返回并提示
        if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
            [self showMBProgressHUDWithSel:@selector(updateDamageinfo)];
            self.actionType = kActionTypeShow;
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
    self.imgview.isExitThread = YES;
    
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
    
    DamageModel *damageModel = [[DamageModel alloc] init];
    damageModel.damageid = damageid;
    damageModel.damagetime = damagetime;
    damageModel.buildingage = buildingage;
    damageModel.damagearea = damagearea;
    damageModel.fieldtype = fieldtype;
    damageModel.damagelevel = damagelevel;
    damageModel.zrcorxq = zrcorxq;
    damageModel.dworzh = dworzh;
    damageModel.fortificationintensity = fortificationintensity;
    damageModel.damagesituation = damagesituation;
    damageModel.damageindex = damageindex;
    damageModel.damagerindex = damagerindex;
    damageModel.housetype = housetype;
    damageModel.pointid = pointid;
    damageModel.upload = upload;
    
    //数据缓存起来
    [CacheUtil shareInstance].cacheDamage = damageModel;
    //本地数据库保存
    BOOL result = [[DamageinfoTableHelper sharedInstance]insertDataWithDamageinfoModel:damageModel];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        //保存图片
        [self saveImages:self.imgview.dataProvider releteId:damageid releteTable:@"DAMAGEINFOTAB"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            //清空imageCollectionView的数据
            self.imgview.dataProvider = [[NSMutableArray alloc] init];
            
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
    self.imgview.isExitThread = YES;
    
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
    
    NSString *damageid = self.damageinfo.damageid;
    NSString *damagetime = self.damageinfo.damagetime;
    NSString *pointid = self.damageinfo.pointid;
    NSString *upload = self.damageinfo.upload;
    
    DamageModel *damageModel = [[DamageModel alloc] init];
    damageModel.damageid = damageid;
    damageModel.damagetime = damagetime;
    damageModel.buildingage = buildingage;
    damageModel.damagearea = damagearea;
    damageModel.fieldtype = fieldtype;
    damageModel.damagelevel = damagelevel;
    damageModel.zrcorxq = zrcorxq;
    damageModel.dworzh = dworzh;
    damageModel.fortificationintensity = fortificationintensity;
    damageModel.damagesituation = damagesituation;
    damageModel.damageindex = damageindex;
    damageModel.damagerindex = damagerindex;
    damageModel.housetype = housetype;
    damageModel.pointid = pointid;
    damageModel.upload = upload;
    
    //数据缓存起来
    [CacheUtil shareInstance].cacheDamage = damageModel;
    //本地数据库保存
    BOOL result = [[DamageinfoTableHelper sharedInstance]updateDataWithDamageinfoModel:damageModel];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        //保存图片
        [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"DAMAGEINFOTAB" Releteid:self.damageinfo.damageid];
        [self saveImages:self.imgview.dataProvider releteId:self.damageinfo.damageid releteTable:@"DAMAGEINFOTAB"];
        
        if ([self.delegate respondsToSelector:@selector(updateDamageinfoSuccess:)]) {
            [self.delegate updateDamageinfoSuccess:self];
        }
    }
}

#pragma mark -- 内部方法 --
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
    NSLog(@"DamageinfoViewController释放了吗。。。。。。。。。。。。。");
}
@end
