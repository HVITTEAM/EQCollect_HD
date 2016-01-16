//
//  PointinfoViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
#define kNormalNavHeight 64
#define kAddNavheight 44

#import "PointinfoViewController.h"
#import "PictureInfoTableHelper.h"
#import "LocationHelper.h"
#import "ChooseIntensityViewController.h"
#import "EarthInfo.h"
#import "AppDelegate.h"
#import "ImageCollectionView.h"
#import "CurrentUser.h"
#import "CacheUtil.h"
#import "ImageCollectionFlowLayout.h"


@interface PointinfoViewController ()<UIAlertViewDelegate,chooseIntensityDelegate,locationHelperDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointidTopCons;        //调查点编号TextField的顶部约束
@property (strong,nonatomic)NSLayoutConstraint *imgViewHeightCons;              //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;              //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;                     //包裹真正内容的容器view

@property (assign,nonatomic)CGFloat navHeight;                  // 导航栏与状态栏总的高度
@property (strong,nonatomic)ImageCollectionView *imgview;       //图片展示控件
@property (strong,nonatomic)LocationHelper *locationHelp;       //用来地址解析的对象

@property (weak, nonatomic) IBOutlet UITextField *pointidTextF;                 //调查点编号
@property (weak, nonatomic) IBOutlet UITextField *earthidTextF;                 //地震编号
@property (weak, nonatomic) IBOutlet UITextField *pointlocationTextF;           //调查点地点
@property (weak, nonatomic) IBOutlet UITextField *pointlonTextF;                //调查点经度
@property (weak, nonatomic) IBOutlet UITextField *pointlatTextF;                //调查点纬度
@property (weak, nonatomic) IBOutlet UITextField *pointnameTextF;               //调查点名称
@property (weak, nonatomic) IBOutlet UITextField *pointtimeTextF;               //生成时间
@property (weak, nonatomic) IBOutlet UITextField *pointgroupTextF;              //小组名称
@property (weak, nonatomic) IBOutlet UITextField *pointPersonTextF;             //小组成员
@property (weak, nonatomic) IBOutlet UITextField *pointintensityTextF;          //评定烈度
@property (weak, nonatomic) IBOutlet UITextView *pointcontentTextV;             //调查简述

@property (strong,nonatomic)NSArray *textInputViews;               //所有的文本输入框

@end

@implementation PointinfoViewController

#pragma mark -- 生命周期方法 --
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;
    
    [self initNavBar];
    
    [self initPointinfoVC];
    
    [self initImageCollectionView];
    
    [self showPointinfoData];
}

#pragma mark -- 初始化子视图方法 --
/**
 *  初始化导航栏
 */
-(void)initNavBar
{
    //默认情况下ScrollView中的内容不会被导航栏遮挡
    self.navHeight = 0;
    if (self.actionType == kActionTypeAdd) {
        self.navigationItem.title = @"调查点";
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(addPointinfo)];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        //当为新增时没有状态栏，高度为44
        self.navHeight = kAddNavheight;
    }
}

/**
 *  初始化调查点信息控制器
 */
-(void)initPointinfoVC
{
    self.pointcontentTextV.backgroundColor = [UIColor whiteColor];
    self.pointcontentTextV.layer.borderColor = HMColor(210, 210, 210).CGColor;
    self.pointcontentTextV.layer.borderWidth = 0.6f;
    self.pointcontentTextV.layer.cornerRadius = 8.0f;
    
    self.textInputViews = @[
                            self.pointidTextF,
                            self.pointtimeTextF,
                            self.pointnameTextF,
                            self.earthidTextF,
                            self.pointlocationTextF,
                            self.pointlonTextF,
                            self.pointlatTextF,
                            self.pointgroupTextF,
                            self.pointPersonTextF,
                            self.pointintensityTextF,
                            self.pointcontentTextV
                            ];
    for (int i = 0;i < self.textInputViews.count-1; i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }
    //pointcontentTextV类型是UITextView,单独处理
    self.pointcontentTextV.delegate = self;
    self.pointcontentTextV.tag = 1000 + self.textInputViews.count-1;

    //设置顶部高约束
    self.pointidTopCons.constant = 20 + self.navHeight;

    [self setActionType:self.actionType];
}

/**
 *  初始化ImageCollectionView
 */
-(void)initImageCollectionView
{
    //创建图片展示控件
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
                                @"pointcontentTextV":self.pointcontentTextV,
                                @"imgview":self.imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pointcontentTextV]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    self.imgViewHeightCons = [NSLayoutConstraint constraintWithItem:_imgview.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:87];
    [self.imgview.collectionView addConstraint:self.imgViewHeightCons];
}

/**
 *  显示数据
 */
-(void)showPointinfoData
{
    if (self.actionType == kActionTypeShow || self.actionType == kactionTypeEdit){    //显示数据
        self.pointidTextF.text = self.pointinfo.pointid;
        self.earthidTextF.text = self.pointinfo.earthid;
        self.pointlocationTextF.text = self.pointinfo.pointlocation;
        self.pointlonTextF.text = self.pointinfo.pointlon;
        self.pointlatTextF.text = self.pointinfo.pointlat;
        self.pointnameTextF.text = self.pointinfo.pointname;
        self.pointtimeTextF.text = self.pointinfo.pointtime;
        self.pointgroupTextF.text = self.pointinfo.pointgroup;
        self.pointPersonTextF.text = self.pointinfo.pointperson;
        self.pointintensityTextF.text = self.pointinfo.pointintensity;
        self.pointcontentTextV.text = self.pointinfo.pointcontent;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *images = [self getImagesWithReleteId:self.pointinfo.pointid releteTable:@"POINTINFOTAB"];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imgview.dataProvider = images;
            });
        });
    }else{      //新增数据
        
        //设置调查点编号
        self.pointidTextF.text = [self createUniqueIdWithAbbreTableName:@"DC"];
        
        //设置小组成员与小组
        self.pointgroupTextF.text = [CurrentUser shareInstance].pointgroup;
        self.pointPersonTextF.text = [CurrentUser shareInstance].pointperson;

        //获取地震编号
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *earthid = appDelegate.earthinfo.earthid;
        if (!earthid) {
            [self getEarthid];
        }else{
             self.earthidTextF.text = earthid;
        }
        
        //设置时间
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        self.pointtimeTextF.text = [formatter stringFromDate:date];
        
        //获取地址
        self.locationHelp = [[LocationHelper alloc] init];
        self.locationHelp.delegate = self;
        [self.locationHelp reverseGeocode];
        
        //设置经纬度
        self.pointlatTextF.text = [NSString stringWithFormat:@"%f",appDelegate.currentCoordinate.latitude];
        self.pointlonTextF.text = [NSString stringWithFormat:@"%f",appDelegate.currentCoordinate.longitude];
        
        //用上一次缓存数据临时显示，减少输入
        PointModel *cache = [CacheUtil shareInstance].cachePoint;
        if (!cache) {
            return;
        }
        self.pointnameTextF.text = cache.pointname;
        self.pointgroupTextF.text = cache.pointgroup;
        self.pointPersonTextF.text = cache.pointperson;
        self.pointintensityTextF.text = cache.pointintensity;
        self.pointcontentTextV.text = cache.pointcontent;
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
    
    if (textField.tag ==1000 || textField.tag == 1001 || textField.tag == 1003) {
        canEdit = NO;
    }else if (textField.tag == 1009){
        canEdit = NO;
        ChooseIntensityViewController *intensityVC = [ChooseIntensityViewController sharedInstance];
        intensityVC.delegate = self;
        UINavigationController *naviga = [[UINavigationController alloc] initWithRootViewController:intensityVC];
        naviga.modalPresentationStyle = UIModalPresentationFormSheet;
        if (self.actionType == kActionTypeAdd) {
           [self presentViewController:naviga animated:YES completion:nil];
        }else{
           [self.parentViewController presentViewController:naviga animated:YES completion:nil];
        }
        
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
    self.pointintensityTextF.text = intensity;
}

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
    self.pointlocationTextF.text = address;
}

#pragma mark -- 内部方法 --
/**
 * 向服务器获取地震编号
 **/
-(void)getEarthid
{
    [CommonRemoteHelper RemoteWithUrl:URL_isstart parameters:nil type:CommonRemoteTypePost success:^(id responseObject) {
    
        NSLog(@"PointinfoViewController 获取 earthid   %@",responseObject);
        NSArray *responseArray = (NSArray *)responseObject;
        if (!responseArray || responseArray.count == 0) {
            //获取失败，则用默认的
            self.earthidTextF.text = kearthidDefault;
        }else{
            //成功,将地震数据保存到AppDelegate中
            AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appdelegate.earthinfo = [EarthInfo objectWithKeyValues:[responseObject firstObject]];
            self.earthidTextF.text = appdelegate.earthinfo.earthid;
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //获取失败，则用默认的
        self.earthidTextF.text = kearthidDefault;
    }];
}

#pragma mark -- 事件方法 --
/**
 * 新增调查点信息
 **/
-(void)addPointinfo
{
    if ([self hasTextBeNullInTextInputViews:self.textInputViews]) {
        return;
    }
    NSString *pointid = self.pointidTextF.text;
    NSString *earthid = self.earthidTextF.text;
    NSString *pointlocation = self.pointlocationTextF.text;
    NSString *pointlon = self.pointlonTextF.text;
    NSString *pointlat = self.pointlatTextF.text;
    NSString *pointname = self.pointnameTextF.text;
    NSString *pointtime = self.pointtimeTextF.text;
    NSString *pointgroup = self.pointgroupTextF.text;
    NSString *pointperson = self.pointPersonTextF.text;
    NSString *pointintensity = self.pointintensityTextF.text;
    NSString *pointcontent = self.pointcontentTextV.text;
    
    NSString *upload = kdidNotUpload;

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:hud];
    hud.labelText = @"请等待...";

    [hud showAnimated:YES whileExecutingBlock:^{
        //创建一个PointModel对象
        PointModel *pointModel = [[PointModel alloc] init];
        pointModel.pointid = pointid;
        pointModel.earthid = earthid;
        pointModel.pointlocation = pointlocation;
        pointModel.pointlon = pointlon;
        pointModel.pointlat = pointlat;
        pointModel.pointname = pointname;
        pointModel.pointtime = pointtime;
        pointModel.pointgroup = pointgroup;
        pointModel.pointperson = pointperson;
        pointModel.pointintensity = pointintensity;
        pointModel.pointcontent = pointcontent;
        pointModel.upload = upload;
        
        //数据缓存起来
        [CacheUtil shareInstance].cachePoint = pointModel;
        
        //本地数据库保存
        BOOL result = [[PointinfoTableHelper sharedInstance] insertDataWithPointinfoModel:pointModel];
        if (!result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            });
        }else{
            //保存图片
            [self saveImages:self.imgview.dataProvider releteId:pointid releteTable:@"POINTINFOTAB"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view endEditing:YES];
                //清空imageCollectionView的数据
                self.imgview.dataProvider = [[NSMutableArray alloc] init];
                
                if ([self.delegate respondsToSelector:@selector(addPointinfoSuccess:)]) {
                    [self.delegate addPointinfoSuccess:self];
                }
            });
        }
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

/**
 * 更新调查点信息
 **/
-(void)updatePointinfo
{
    if ([self  hasTextBeNullInTextInputViews:self.textInputViews]) {
        return;
    }
    
    NSString *pointid = self.pointinfo.pointid;
    NSString *earthid = self.earthidTextF.text;
    NSString *pointlocation = self.pointlocationTextF.text;
    NSString *pointlon = self.pointlonTextF.text;
    NSString *pointlat = self.pointlatTextF.text;
    NSString *pointname = self.pointnameTextF.text;
    NSString *pointtime = self.pointinfo.pointtime;
    NSString *pointgroup = self.pointgroupTextF.text;
    NSString *pointperson = self.pointPersonTextF.text;
    NSString *pointintensity = self.pointintensityTextF.text;
    NSString *pointcontent = self.pointcontentTextV.text;
    NSString *upload = self.pointinfo.upload;

    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"请等待...";
    
    [hud showAnimated:YES whileExecutingBlock:^{
        
        //创建一个PointModel对象
        PointModel *pointModel = [[PointModel alloc] init];
        pointModel.pointid = pointid;
        pointModel.earthid = earthid;
        pointModel.pointlocation = pointlocation;
        pointModel.pointlon = pointlon;
        pointModel.pointlat = pointlat;
        pointModel.pointname = pointname;
        pointModel.pointtime = pointtime;
        pointModel.pointgroup = pointgroup;
        pointModel.pointperson = pointperson;
        pointModel.pointintensity = pointintensity;
        pointModel.pointcontent = pointcontent;
        pointModel.upload = upload;
        
        //数据缓存起来
        [CacheUtil shareInstance].cachePoint = pointModel;
        
        //更新本地数据库
        BOOL result = [[PointinfoTableHelper sharedInstance]updateDataWithPointinfoModel:pointModel];
        if (!result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            });
        }else{
            //保存图片
            [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"POINTINFOTAB" Releteid:self.pointinfo.pointid];
            [self saveImages:self.imgview.dataProvider releteId:pointid releteTable:@"POINTINFOTAB"];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view endEditing:YES];
                
                if ([self.delegate respondsToSelector:@selector(updatePointinfoSuccess:)]) {
                    [self.delegate updatePointinfoSuccess:self];
                }
             });
        }
    } completionBlock:^{
        [hud removeFromSuperview];
    }];
}

/**
 *  重写父类方法,判断是否有文本框内容为空
 */
-(BOOL)hasTextBeNullInTextInputViews:(NSArray *)textInputViews
{
    //判断文本输入框是否为空，如果为空则提示并返回
    for (int i=0; i<textInputViews.count; i++) {
        if (i!=textInputViews.count-1) {
            UITextField *textF = (UITextField *)textInputViews[i];
            if (textF.text ==nil || textF.text.length <=0) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"所填项目不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return YES;
            }
        }else{
            UITextView *textV = (UITextView *)textInputViews[i];
            if (textV.text ==nil || textV.text.length <=0) {
                [[[UIAlertView alloc] initWithTitle:nil message:@"数据不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
                return YES;
            }
        }
    }
    return NO;
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
    NSLog(@"PointinfoViewController释放了吗。。。。。。。。。。。。。");
}

@end

