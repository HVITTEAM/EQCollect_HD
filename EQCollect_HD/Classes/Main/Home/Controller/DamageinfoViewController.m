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

@interface DamageinfoViewController ()<UIAlertViewDelegate,chooseIntensityDelegate>
{
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
    UIBarButtonItem *_rigthItem;      //导航栏右侧按钮
    ImageCollectionView *imgview;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *damageidTopCons;         //房屋震害编号TextField顶部约束
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *damageidWidthCons;        //房屋震害编号TextField宽约束
@property (strong,nonatomic)NSLayoutConstraint *imgViewHeightCons;  //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;  //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;         //包裹真正内容的容器view

@property (weak, nonatomic) IBOutlet UITextField *damageidTextF;                   //房屋震害编号
@property (weak, nonatomic) IBOutlet UITextField *damagetimeTextF;                 //调查时间
@property (weak, nonatomic) IBOutlet UITextField *damageaddressTextF;              //地址
@property (weak, nonatomic) IBOutlet UITextField *damageintensityTextF;            //烈度
@property (weak, nonatomic) IBOutlet UITextField *zrcorxqTextF;                    //自然村或小区
@property (weak, nonatomic) IBOutlet UITextField *dworzhTextF;                     //单位或住户
@property (weak, nonatomic) IBOutlet UITextField *fortificationintensityTextF;     //设防烈度
@property (weak, nonatomic) IBOutlet UITextField *damagesituationTextF;            //破坏情况
@property (weak, nonatomic) IBOutlet UITextField *damageindexTextF;                //震害指数
@property (weak, nonatomic) IBOutlet UITextField *houseTypeTextF;                  //房屋类型

@property (strong,nonatomic)NSArray *textInputViews;                //所有的文本输入框
@property (strong,nonatomic)NSArray *intensityItems;                //烈度选项
@property (strong,nonatomic)NSArray *fortificationintensityItems;   //设防烈度选项
@property (strong,nonatomic)NSArray *damagesituationItems;          //破坏情况选项
@property (strong,nonatomic)NSArray *damageindexItems;              //震害指数选项
@property (strong,nonatomic)NSArray *houseTypeItems;                //房屋类型选项

@end

@implementation DamageinfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;

    [self initDamageinfo];
    [self initImageCollectionView];
    [self showDamageinfoData];
}

/**
 *  初始化房屋震害信息控制器
 */
-(void)initDamageinfo
{
    self.navigationItem.title = @"房屋震害";
    
    //默认有状态栏，高度为64
    _navHeight = kNormalNavHeight;
    
    _rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemTap:)];
    self.navigationItem.rightBarButtonItem = _rigthItem;
//    if (![self.damageinfo.upload isEqualToString:@"1"]) {
//        self.navigationItem.rightBarButtonItem = _rigthItem;
//    }
    
    if (self.actionType == kActionTypeAdd) {
        //设置导航栏按钮
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        
        _rigthItem.title = @"确定";
        
        //当为新增时没有状态栏，高度为44
        _navHeight = kAddNavheight;
        //启用交互
        [self.view setUserInteractionEnabled:YES];
    }
     self.textInputViews = @[
                            self.damageidTextF,
                            self.damagetimeTextF,
                            self.zrcorxqTextF,
                            self.dworzhTextF,
                            self.fortificationintensityTextF,
                            self.damageintensityTextF,
                            self.damagesituationTextF,
                            self.damageindexTextF,
                            self.houseTypeTextF,
                            self.damageaddressTextF
                            ];
    for (int i = 0;i<self.textInputViews.count;i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }

    self.intensityItems = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    self.fortificationintensityItems = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    self.damagesituationItems = @[@"严重",@"中等",@"轻微"];
    self.damageindexItems = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
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
                                @"damageaddressTextF":self.damageaddressTextF,
                                @"imgview":imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[damageaddressTextF]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
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
        self.damageaddressTextF.text = self.damageinfo.damageaddress;
        self.damageintensityTextF.text = self.damageinfo.damageintensity;
        self.zrcorxqTextF.text = self.damageinfo.zrcorxq;
        self.dworzhTextF.text = self.damageinfo.dworzh;
        self.fortificationintensityTextF.text = self.damageinfo.fortificationintensity;
        self.damagesituationTextF.text = self.damageinfo.damagesituation;
        self.damageindexTextF.text = self.damageinfo.damageindex;
        self.houseTypeTextF.text = self.damageinfo.housetype;
        
        //[self getimage];
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
        [formatter setDateFormat:@"MM-dd HH:mm"];
        self.damagetimeTextF.text = [formatter stringFromDate:date];
    }
}

/**
 *  ActionType属性的 setter 方法
 */
-(void)setActionType:(ActionType)actionType
{
    _actionType = actionType;
    if (actionType == kActionTypeShow) {
        for (UITextField *txt in self.textInputViews) {
            txt.userInteractionEnabled = NO;
        }
    }else{
        if ([self.damageinfo.upload isEqualToString:@"1"]) {
            self.damageintensityTextF.userInteractionEnabled = YES;
            self.fortificationintensityTextF.userInteractionEnabled = YES;
        }else{
            for (UITextField *txt in self.textInputViews) {
                txt.userInteractionEnabled = YES;
            }
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
    }else if (textField.tag == 1004){
        canEdit = NO;
        ChooseIntensityViewController *intensityVC = [ChooseIntensityViewController sharedInstance];
        intensityVC.delegate = self;
        UINavigationController *naviga = [[UINavigationController alloc] initWithRootViewController:intensityVC];
        naviga.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:naviga animated:YES completion:nil];
    }else if (textField.tag == 1005){
        canEdit = NO;
        ChooseIntensityViewController *intensityVC = [ChooseIntensityViewController sharedInstance];
        intensityVC.delegate = self;
        UINavigationController *naviga = [[UINavigationController alloc] initWithRootViewController:intensityVC];
        naviga.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:naviga animated:YES completion:nil];
    }else if (textField.tag == 1006){
        canEdit = NO;
        [self showAlertViewWithTextField:textField items:self.damagesituationItems];
    }else if (textField.tag == 1007){
        canEdit = NO;
        [self showAlertViewWithTextField:textField items:self.damageindexItems];
    }else if (textField.tag == 1008){
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
    }else{
        if (self.actionType == kActionTypeAdd) {
            //判断是否有文本框为空，有空则返回并提示
            if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
                [self showMBProgressHUDWithSel:@selector(addDamageinfo)];
            }
        }else{
            //判断是否有文本框为空，有空则返回并提示
            if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
                
                if ([self.damageinfo.upload isEqualToString:kdidUpload]) {
                    [self showMBProgressHUDWithSel:@selector(updateNetWorkDamageInfo)];
                }else{
                    [self showMBProgressHUDWithSel:@selector(updateDamageinfo)];
                    self.actionType = kActionTypeShow;
                }
                
                //[self.view endEditing:YES];
                self.navigationItem.rightBarButtonItem.title = @"编辑";
                
            }
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
    NSString *damageaddress = self.damageaddressTextF.text;
    NSString *damageintensity = self.damageintensityTextF.text;
    NSString *zrcorxq = self.zrcorxqTextF.text;
    NSString *dworzh = self.dworzhTextF.text;
    NSString *fortificationintensity = self.fortificationintensityTextF.text;
    NSString *damagesituation = self.damagesituationTextF.text;
    NSString *damageindex = self.damageindexTextF.text;
    NSString *housetype = self.houseTypeTextF.text;
    
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          damageid,@"damageid",
                          damagetime,@"damagetime",
                          damageaddress,@"damageaddress",
                          damageintensity, @"damageintensity",
                          zrcorxq, @"zrcorxq",
                          dworzh,@"dworzh",
                          fortificationintensity,@"fortificationintensity",
                          damagesituation,@"damagesituation",
                          damageindex,@"damageindex",
                          housetype,@"housetype",
                          self.pointid,@"pointid",
                          kdidNotUpload,@"upload",
                          nil];
    
    BOOL result = [[DamageinfoTableHelper sharedInstance] insertDataWith:dict];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        
        //        [self saveImagesWithReleteId:damageid releteTable:@"DAMAGEINFOTAB"];
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

   // NSString *damageid = self.damageidTextF.text;
    //NSString *damagetime = self.damagetimeTextF.text;
    NSString *damageaddress = self.damageaddressTextF.text;
    NSString *damageintensity = self.damageintensityTextF.text;
    NSString *zrcorxq = self.zrcorxqTextF.text;
    NSString *dworzh = self.dworzhTextF.text;
    NSString *fortificationintensity = self.fortificationintensityTextF.text;
    NSString *damagesituation = self.damagesituationTextF.text;
    NSString *damageindex = self.damageindexTextF.text;
    NSString *housetype = self.houseTypeTextF.text;
    
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.damageinfo.damageid,@"damageid",
                          self.damageinfo.damagetime,@"damagetime",
                          damageaddress,@"damageaddress",
                          damageintensity, @"damageintensity",
                          zrcorxq, @"zrcorxq",
                          dworzh,@"dworzh",
                          fortificationintensity,@"fortificationintensity",
                          damagesituation,@"damagesituation",
                          damageindex,@"damageindex",
                          housetype,@"housetype",
                          self.damageinfo.pointid,@"pointid",
                          self.damageinfo.upload,@"upload",
                          nil];
    
    BOOL result = [[DamageinfoTableHelper sharedInstance] updateDataWith:dict];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"DAMAGEINFOTAB" Releteid:self.damageinfo.damageid];
        //[self saveImagesWithReleteId:self.damageinfo.damageid releteTable:@"DAMAGEINFOTAB"];
        [self saveImages:imgview.dataProvider releteId:self.damageinfo.damageid releteTable:@"DAMAGEINFOTAB"];
        
        if ([self.delegate respondsToSelector:@selector(updateDamageinfoSuccess:)]) {
            [self.delegate updateDamageinfoSuccess:self];
        }
    }
}


-(void)updateNetWorkDamageInfo
{
    //防止异步加载图片出错
    imgview.isExitThread = YES;
    
    NSString *damageid = self.damageinfo.damageid;
    NSString *damagetime = self.damagetimeTextF.text;
    NSString *damageaddress = self.damageaddressTextF.text;
    NSString *damageintensity0 = self.damageintensityTextF.text;
    NSString *damageintensity = [self switchRomeNumToNum:self.damageintensityTextF.text];
    NSString *zrcorxq = self.zrcorxqTextF.text;
    NSString *dworzh = self.dworzhTextF.text;
    NSString *fortificationintensity0 = self.fortificationintensityTextF.text;
    NSString *fortificationintensity = [self switchRomeNumToNum:self.fortificationintensityTextF.text];
    NSString *damagesituation = self.damagesituationTextF.text;
    NSString *damageindex = self.damageindexTextF.text;
    NSString *housetype = self.houseTypeTextF.text;
    NSString *pointid = self.damageinfo.pointid;
    NSString *upload = self.damageinfo.upload;
    
    //创建字典对象作为上传参数
    NSMutableDictionary *parameters1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 damageid,@"damageid",
                                 //model.damagetime,@"damagetime",
                                 damageaddress,@"damageaddress",
                                 damageintensity, @"damageintensity",
                                 zrcorxq, @"zrcorxq",
                                 dworzh,@"dworzh",
                                 fortificationintensity,@"fortificationintensity",
                                 damagesituation,@"damagesituation",
                                 damageindex,@"damageindex",
                                 housetype,@"housetype",
                                 pointid,@"pointid",
                                 //@"0",@"upload",
                                 nil];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_updatedamage parameters:parameters1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"数据上传成功: %@", responseObject);
        //上传数据成功则更新本地数
        
        parameters1[@"damagetime"] = damagetime;
        parameters1[@"upload"] = upload;
        parameters1[@"damageintensity"] = damageintensity0;
        parameters1[@"fortificationintensity"] = fortificationintensity0;
        
        BOOL result = [[DamageinfoTableHelper sharedInstance]updateDataWith:parameters1];
        if (result) {
            self.actionType = kActionTypeShow;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"数据上传失败:");
    }];
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
