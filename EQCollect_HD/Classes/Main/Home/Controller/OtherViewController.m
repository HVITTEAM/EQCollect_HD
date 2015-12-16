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
#import "PictureMode.h"
#import "OtherTableHelper.h"
#import "LocationHelper.h"
#import "AppDelegate.h"

@interface OtherViewController ()<locationHelperDelegate>
{
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
    UIBarButtonItem *_rigthItem;      //导航栏右侧按钮
    ImageCollectionView *imgview;
    
    LocationHelper *_locationHelp;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherIdTextFTopCons;
@property (strong,nonatomic)NSLayoutConstraint *imgViewHeightCons;  //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;  //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;         //包裹真正内容的容器view

@property (weak, nonatomic) IBOutlet UITextField *otherIdTextF;
@property (weak, nonatomic) IBOutlet UITextField *otherTimeTextF;
@property (weak, nonatomic) IBOutlet UITextField *otherLonTextF;
@property (weak, nonatomic) IBOutlet UITextField *otherLatTextF;
@property (weak, nonatomic) IBOutlet UITextField *otherAddressTextF;
@property (weak, nonatomic) IBOutlet UITextView *otherTextView;

@property (strong,nonatomic)NSArray *textInputViews;           //所有的文本输入框

@end

@implementation OtherViewController
#pragma  mark --生命周期方法--
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initOther];
    [self initImageCollectionView];
    [self showOtherInfoData];
}

#pragma  mark --getter 和 setter 方法--

#pragma  mark --初始化界面方法--
/**
 *  初始化其他信息控制器
 */
-(void)initOther
{
    _navHeight = 64;
    
    _rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemTap:)];
    self.navigationItem.rightBarButtonItem = _rigthItem;
    if ([self.otherInfor.upload isEqualToString:kdidNotUpload]) {
        self.navigationItem.rightBarButtonItem = _rigthItem;
    }
    
    if (self.actionType == kActionTypeAdd) {
        //设置导航栏按钮
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        
        _rigthItem.title = @"确定";
        
        //当为新增时没有状态栏，高度为44
        _navHeight = kAddNavheight;
    }
    
    self.textInputViews = @[
                            self.otherIdTextF,
                            self.otherTimeTextF,
                            self.otherLonTextF,
                            self.otherLatTextF,
                            self.otherAddressTextF,
                            self.otherTextView,
                            ];
    for (int i = 0;i<self.textInputViews.count-1;i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }
    self.otherTextView.delegate = self;

    //设置顶部高约束
    self.otherIdTextFTopCons.constant = 20+_navHeight;
    
    //[self setActionType:self.actionType];

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
                                @"otherTextView":self.otherTextView,
                                @"imgview":imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[otherTextView]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    self.imgViewHeightCons = [NSLayoutConstraint constraintWithItem:imgview.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:87];
    [imgview.collectionView addConstraint:self.imgViewHeightCons];
}

/**
 *  显示数据
 */
-(void)showOtherInfoData
{
    if (self.actionType == kActionTypeShow || self.actionType == kactionTypeEdit) {
        self.self.otherIdTextF.text = self.otherInfor.otherid;
        self.self.otherTimeTextF.text = self.otherInfor.othertime;
        self.self.otherLonTextF.text = self.otherInfor.otherlon;
        self.self.otherLatTextF.text = self.otherInfor.otherlat;
        self.self.otherAddressTextF.text = self.otherInfor.otheraddress;
        self.self.otherTextView.text = self.otherInfor.othercontent;
 
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *images = [self getImagesWithReleteId:self.otherInfor.otherid releteTable:@"OTHERTAB"];
            dispatch_async(dispatch_get_main_queue(), ^{
                imgview.dataProvider = images;
            });
        });
        
    }else {
        
        self.otherIdTextF.text = [self createUniqueIdWithAbbreTableName:@"QT"];
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss "];
        self.otherTimeTextF.text = [formatter stringFromDate:date];
        
        _locationHelp = [[LocationHelper alloc] init];
        _locationHelp.delegate = self;
        [_locationHelp reverseGeocode];
        AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.otherLatTextF.text = [NSString stringWithFormat:@"%f",appdelegate.currentCoordinate.latitude];
        self.otherLonTextF.text = [NSString stringWithFormat:@"%f",appdelegate.currentCoordinate.longitude];

    }
}

#pragma  mark --事locationHelperDelegate方法--
-(void)reverseGeocodeFailure
{
    [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"无法解析当前地址，您可手动输入地址" delegate:nil
                      cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
}

-(void)reverseGeocodeSuccess:(NSString *)address
{
    self.otherAddressTextF.text = address;
}

#pragma  mark --事件方法--
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
            //[self.view endEditing:YES];
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
    imgview.isExitThread = YES;
    
    NSString *otherId = self.otherIdTextF.text;
    NSString *otherTime = self.otherTimeTextF.text;
    NSString *otherLon = self.otherLonTextF.text;
    NSString *otherLat = self.otherLatTextF.text;
    NSString *otherAddress = self.otherAddressTextF.text;
    NSString *otherContent = self.otherTextView.text;
    
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          otherId,@"otherid",
                          otherContent,@"othercontent",
                          otherLon,@"otherlon",
                          otherLat, @"otherlat",
                          otherAddress, @"otheraddress",
                          otherTime,@"othertime",
                          self.pointid,@"pointid",
                          kdidNotUpload,@"upload",
                          nil];

    
    BOOL result = [[OtherTableHelper sharedInstance] insertDataWith:dict];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
    
        [self saveImages:imgview.dataProvider releteId:otherId releteTable:@"OTHERTAB"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.view endEditing:YES];
            //清空imageCollectionView的数据
            imgview.dataProvider = [[NSMutableArray alloc] init];
            //防止循环引用导致无法释放当前这个控制器
            imgview.nav = nil;
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
    imgview.isExitThread = YES;
    
//    NSString *otherId = self.otherIdTextF.text;
//    NSString *otherTime = self.otherTimeTextF.text;
    NSString *otherLon = self.otherLonTextF.text;
    NSString *otherLat = self.otherLatTextF.text;
    NSString *otherAddress = self.otherAddressTextF.text;
    NSString *otherContent = self.otherTextView.text;
    
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.otherInfor.otherid,@"otherid",
                          otherContent,@"othercontent",
                          otherLon,@"otherlon",
                          otherLat, @"otherlat",
                          otherAddress, @"otheraddress",
                          self.otherInfor.othertime,@"othertime",
                          self.otherInfor.pointid,@"pointid",
                          self.otherInfor.upload,@"upload",
                          nil];
    
    BOOL result = [[OtherTableHelper sharedInstance] updateDataWith:dict];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"OTHERTAB" Releteid:self.otherInfor.otherid];
        [self saveImages:imgview.dataProvider releteId:self.otherInfor.otherid releteTable:@"OTHERTAB"];
        
        if ([self.delegate respondsToSelector:@selector(updateOtherInfoSuccess:)]) {
            [self.delegate updateOtherInfoSuccess:self];
        }
    }
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
