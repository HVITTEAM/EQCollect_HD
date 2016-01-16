//
//  OtherViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/12/10.
//  Copyright © 2015年 董徐维. All rights reserved.
//
#define kNormalNavHeight 64
#define kAddNavheight 44

#import "OtherViewController.h"
#import "ImageCollectionView.h"
#import "OtherTableHelper.h"
#import "LocationHelper.h"
#import "AppDelegate.h"
#import "CacheUtil.h"
#import "ImageCollectionFlowLayout.h"

@interface OtherViewController ()<locationHelperDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherIdTextFTopCons;    //其它编号TextField顶部约束
@property (strong,nonatomic)NSLayoutConstraint *imgViewHeightCons;               //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;               //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;                      //包裹真正内容的容器view

@property (assign,nonatomic)CGFloat navHeight;                  // 导航栏与状态栏总的高度
@property (strong,nonatomic)ImageCollectionView *imgview;       //图片展示控件
@property (strong,nonatomic)LocationHelper *locationHelp;       //用来地址解析的对象

@property (weak, nonatomic) IBOutlet UITextField *otherIdTextF;                 //其它编号
@property (weak, nonatomic) IBOutlet UITextField *otherTimeTextF;               //调查时间
@property (weak, nonatomic) IBOutlet UITextField *otherLonTextF;                //经度
@property (weak, nonatomic) IBOutlet UITextField *otherLatTextF;                //纬度
@property (weak, nonatomic) IBOutlet UITextField *otherAddressTextF;            //地址
@property (weak, nonatomic) IBOutlet UITextView *otherContentTextView;          //内容

@property (strong,nonatomic)NSArray *textInputViews;           //所有的文本输入框

@end

@implementation OtherViewController
#pragma  mark -- 生命周期方法 --
- (void)viewDidLoad {
    [super viewDidLoad];
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;
    
    [self initNavBar];
    
    [self initOther];
    
    [self initImageCollectionView];
    
    [self showOtherInfoData];
}

#pragma  mark -- 初始化界面方法 --
/**
 *  初始化导航栏
 */
-(void)initNavBar
{
    //默认有状态栏，高度为64
    self.navHeight = kNormalNavHeight;
    
    self.navigationItem.title = @"其它";
    UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemTap:)];
    //没上传可以编辑,上传了不可编辑
    if ([self.otherInfor.upload isEqualToString:kdidNotUpload]) {
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
 *  初始化其他信息控制器
 */
-(void)initOther
{
    self.otherContentTextView.backgroundColor = [UIColor whiteColor];
    self.otherContentTextView.layer.borderColor = HMColor(210, 210, 210).CGColor;
    self.otherContentTextView.layer.borderWidth = 0.6f;
    self.otherContentTextView.layer.cornerRadius = 8.0f;
    
    self.textInputViews = @[
                            self.otherIdTextF,
                            self.otherTimeTextF,
                            self.otherLonTextF,
                            self.otherLatTextF,
                            self.otherAddressTextF,
                            self.otherContentTextView,
                            ];
    for (int i = 0;i<self.textInputViews.count-1;i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }
    self.otherContentTextView.delegate = self;
    self.otherContentTextView.tag = 1000 + self.textInputViews.count - 1;

    //设置顶部高约束
    self.otherIdTextFTopCons.constant = 20 + self.navHeight;
    
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
                                @"otherTextView":self.otherContentTextView,
                                @"imgview":self.imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[otherTextView]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    self.imgViewHeightCons = [NSLayoutConstraint constraintWithItem:self.imgview.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:87];
    [self.imgview.collectionView addConstraint:self.imgViewHeightCons];
}

/**
 *  显示数据
 */
-(void)showOtherInfoData
{
    if (self.actionType == kActionTypeShow || self.actionType == kactionTypeEdit) {     //显示数据
        self.self.otherIdTextF.text = self.otherInfor.otherid;
        self.self.otherTimeTextF.text = self.otherInfor.othertime;
        self.self.otherLonTextF.text = self.otherInfor.otherlon;
        self.self.otherLatTextF.text = self.otherInfor.otherlat;
        self.self.otherAddressTextF.text = self.otherInfor.otheraddress;
        self.self.otherContentTextView.text = self.otherInfor.othercontent;
 
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *images = [self getImagesWithReleteId:self.otherInfor.otherid releteTable:@"OTHERTAB"];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imgview.dataProvider = images;
            });
        });
    }else {        //新增数据
        //设置其它编号
        self.otherIdTextF.text = [self createUniqueIdWithAbbreTableName:@"QT"];
        //设置时间
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss "];
        self.otherTimeTextF.text = [formatter stringFromDate:date];
        
        //获取地址
        self.locationHelp = [[LocationHelper alloc] init];
        self.locationHelp.delegate = self;
        [self.locationHelp reverseGeocode];
        
        //设置经纬度
        AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.otherLatTextF.text = [NSString stringWithFormat:@"%f",appdelegate.currentCoordinate.latitude];
        self.otherLonTextF.text = [NSString stringWithFormat:@"%f",appdelegate.currentCoordinate.longitude];
        
        //用上一次缓存数据临时显示，减少输入
        OtherModel *cache = [CacheUtil shareInstance].cacheOther;
        if (!cache) {
            return;
        }
        self.self.otherAddressTextF.text = cache.otheraddress;
        self.self.otherContentTextView.text = cache.othercontent;
    }
}

#pragma  mark -- getter和setter方法 --
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
#pragma mark locationHelperDelegate
/**
 *  逆地理编码失败后回调
 */
-(void)reverseGeocodeFailure
{
    [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"无法解析当前地址，您可手动输入地址" delegate:nil
                      cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
}

/**
 *  逆地理编码成功后回调
 */
-(void)reverseGeocodeSuccess:(NSString *)address
{
    self.otherAddressTextF.text = address;
}

#pragma  mark -- 事件方法 --
/**
 *  导航栏右侧按钮点击调用
 */
-(void)rightItemTap:(UIBarButtonItem *)sender
{
    if (self.actionType == kActionTypeShow) {
        self.navigationItem.rightBarButtonItem.title = @"确定";
        self.actionType = kactionTypeEdit;
    }else if(self.actionType == kActionTypeAdd){
        if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
            [self showMBProgressHUDWithSel:@selector(addOtherinfo)];
        }
    }else{
        if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
            [self showMBProgressHUDWithSel:@selector(updateOtherinfo)];
            self.navigationItem.rightBarButtonItem.title = @"编辑";
            self.actionType = kActionTypeShow;
        }
    }
}

/**
 *  新增其他信息
 */
-(void)addOtherinfo
{
    //防止异步加载图片出错
    self.imgview.isExitThread = YES;
    
    NSString *otherId = self.otherIdTextF.text;
    NSString *otherTime = self.otherTimeTextF.text;
    NSString *otherLon = self.otherLonTextF.text;
    NSString *otherLat = self.otherLatTextF.text;
    NSString *otherAddress = self.otherAddressTextF.text;
    NSString *otherContent = self.otherContentTextView.text;
    
    NSString *pointid = self.pointid;
    NSString *upload = kdidNotUpload;
    
    OtherModel *otherModel = [[OtherModel alloc] init];
    otherModel.otherid = otherId;
    otherModel.othercontent = otherContent;
    otherModel.otherlon = otherLon;
    otherModel.otherlat = otherLat;
    otherModel.otheraddress = otherAddress;
    otherModel.othertime = otherTime;
    otherModel.pointid = pointid;
    otherModel.upload = upload;
    
    //数据缓存起来
    [CacheUtil shareInstance].cacheOther = otherModel;
    //本地数据库保存
    BOOL result = [[OtherTableHelper sharedInstance]insertDataWithOtherinfoModel:otherModel];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        //保存图片
        [self saveImages:self.imgview.dataProvider releteId:otherId releteTable:@"OTHERTAB"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            //清空imageCollectionView的数据
            self.imgview.dataProvider = [[NSMutableArray alloc] init];
            
            if ([self.delegate respondsToSelector:@selector(addOtherInfoSuccess:)]) {
                [self.delegate addOtherInfoSuccess:self];
            }
        });
    }
}

/**
 * 更新其他信息
 **/
-(void)updateOtherinfo
{
    //防止异步加载图片出错
    self.imgview.isExitThread = YES;

    NSString *otherLon = self.otherLonTextF.text;
    NSString *otherLat = self.otherLatTextF.text;
    NSString *otherAddress = self.otherAddressTextF.text;
    NSString *otherContent = self.otherContentTextView.text;
    
    NSString *otherId = self.otherInfor.otherid;
    NSString *otherTime = self.otherInfor.othertime;
    NSString *pointid = self.otherInfor.pointid;
    NSString *upload = self.otherInfor.upload;

    OtherModel *otherModel = [[OtherModel alloc] init];
    otherModel.otherid = otherId;
    otherModel.othercontent = otherContent;
    otherModel.otherlon = otherLon;
    otherModel.otherlat = otherLat;
    otherModel.otheraddress = otherAddress;
    otherModel.othertime = otherTime;
    otherModel.pointid = pointid;
    otherModel.upload = upload;
    
    //数据缓存起来
    [CacheUtil shareInstance].cacheOther = otherModel;
    //本地数据库保存
    BOOL result = [[OtherTableHelper sharedInstance]updateDataWithOtherinfoModel:otherModel];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        //保存图片
        [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"OTHERTAB" Releteid:self.otherInfor.otherid];
        [self saveImages:self.imgview.dataProvider releteId:self.otherInfor.otherid releteTable:@"OTHERTAB"];
        
        if ([self.delegate respondsToSelector:@selector(updateOtherInfoSuccess:)]) {
            [self.delegate updateOtherInfoSuccess:self];
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
    NSLog(@"DamageinfoViewController释放了吗。。。。。。。。。。。。。");
}

@end
