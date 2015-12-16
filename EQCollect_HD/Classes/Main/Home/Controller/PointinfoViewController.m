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
#import "PictureMode.h"
#import "LocationHelper.h"
#import "ChooseIntensityViewController.h"
#import "EarthInfo.h"
#import "AppDelegate.h"
#import "ImageCollectionView.h"


@interface PointinfoViewController ()<UIAlertViewDelegate,chooseIntensityDelegate,locationHelperDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointidTopCons;        //调查点编号TextField的顶部约束
@property (strong,nonatomic)NSLayoutConstraint *imgViewHeightCons;  //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;  //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;         //包裹真正内容的容器view

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

@property (strong,nonatomic)NSArray *pointintensityItems;   //评定烈度选项

@end

@implementation PointinfoViewController
{
    CGFloat _navHeight;       // 导航栏与状态栏总的高度
    LocationHelper *_locationHelp;
    ImageCollectionView *imgview;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;
    
    [self initPointinfoVC];
    [self initImageCollectionView];
    [self showPointinfoData];
}

/**
 *  初始化调查点信息控制器
 */
-(void)initPointinfoVC
{
    //默认情况下ScrollView中的内容不会被导航栏遮挡
    _navHeight = 0;
    if (self.actionType == kActionTypeAdd ) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(addPointinfo)];
        self.navigationItem.rightBarButtonItem = rightItem;
        
        //当为新增时没有状态栏，高度为44
        _navHeight = kAddNavheight;
    }    
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
    //pointcontentTextV类型是UITextView单独处理
    self.pointcontentTextV.delegate = self;
    self.pointcontentTextV.tag = 1000 + self.textInputViews.count-1;
    
    self.pointintensityItems = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    //设置顶部高约束
    self.pointidTopCons.constant = 20+_navHeight;

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
    if (self.actionType == kActionTypeAdd) {
        imgview.nav = self.navigationController;
    }else{
       imgview.nav = (UINavigationController *)self.preVc;
    }
    
    //[self addChildViewController:imgview];
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
                                @"pointcontentTextV":self.pointcontentTextV,
                                @"imgview":imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[pointcontentTextV]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    self.imgViewHeightCons = [NSLayoutConstraint constraintWithItem:imgview.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:87];
    [imgview.collectionView addConstraint:self.imgViewHeightCons];
}


/**
 *  显示数据
 */
-(void)showPointinfoData
{
    if (self.actionType == kActionTypeShow || self.actionType == kactionTypeEdit)
    {
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
                imgview.dataProvider = images;
            });
        });
    }else
    {
        self.pointidTextF.text = [self createUniqueIdWithAbbreTableName:@"DC"];
        
        UserModel *model = [ArchiverCacheHelper getLocaldataBykey:User_Archiver_Key filePath:User_Archiver_Path];
        if (!model) {
            model = [[UserModel alloc] init];
        }
        self.pointgroupTextF.text = model.pointgroup;
        self.pointPersonTextF.text = model.pointperson;

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSString *earthid = appDelegate.earthinfo.earthid;
        if (!earthid) {
            [self getEarthid];
        }else{
             self.earthidTextF.text = earthid;
        }
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        self.pointtimeTextF.text = [formatter stringFromDate:date];
        
        _locationHelp = [[LocationHelper alloc] init];
        _locationHelp.delegate = self;
        [_locationHelp reverseGeocode];
        AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.pointlatTextF.text = [NSString stringWithFormat:@"%f",appdelegate.currentCoordinate.latitude];
        self.pointlonTextF.text = [NSString stringWithFormat:@"%f",appdelegate.currentCoordinate.longitude];
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
        for (UIView *txt in self.textInputViews) {
            txt.userInteractionEnabled = NO;
        }
    }else{
        for (UIView *txt in self.textInputViews) {
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
           [self.preVc presentViewController:naviga animated:YES completion:nil];
        }
        
    }else{
    canEdit = YES;
    }
    return canEdit;
}

-(void)viewController:(ChooseIntensityViewController *)chooseIntensityVC selectedIntensity:(NSString *)intensity
{
    self.pointintensityTextF.text = intensity;
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
 * 地震编号
 **/
-(void)getEarthid
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_isstart parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"获取 earthid   %@",responseObject);
        NSArray *responseArray = (NSArray *)responseObject;
        if (!responseArray || responseArray.count == 0) {
            self.earthidTextF.text = kearthidDefault;
            [[[UIAlertView alloc] initWithTitle:nil message:@"没有获取到地震编号" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }else{
            //成功
            AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appdelegate.earthinfo = [EarthInfo objectWithKeyValues:[responseObject firstObject]];
            self.earthidTextF.text = appdelegate.earthinfo.earthid;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取 earthid 失败");
        
    }];
}

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
        
        //创建字典对象并向表中插和数据
        NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              pointid,@"pointid",
                              earthid,@"earthid",
                              pointlocation,@"pointlocation",
                              pointlon, @"pointlon",
                              pointlat, @"pointlat",
                              pointname,@"pointname",
                              pointtime,@"pointtime",
                              pointgroup,@"pointgroup",
                              pointperson,@"pointperson",
                              pointintensity,@"pointintensity",
                              pointcontent,@"pointcontent",
                              upload,@"upload",nil];
        
        BOOL result = [[PointinfoTableHelper sharedInstance] insertDataWith:dict];
        if (!result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            });
          }else{
            [self saveImages:imgview.dataProvider releteId:pointid releteTable:@"POINTINFOTAB"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view endEditing:YES];
                //清空imageCollectionView的数据
                imgview.dataProvider = [[NSMutableArray alloc] init];
                //防止循环引用导致无法释放当前这个控制器
                imgview.nav = nil;
                
                if ([self.delegate respondsToSelector:@selector(addPointinfoSuccess:)]) {
                    [self.delegate addPointinfoSuccess:self];
                }
            });
        }

    } completionBlock:^{
        [hud removeFromSuperview];
        //[hud release];
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
        
        //创建字典对象并向表中插和数据
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                              pointid,@"pointid",
                              earthid,@"earthid",
                              pointlocation,@"pointlocation",
                              pointlon, @"pointlon",
                              pointlat, @"pointlat",
                              pointname,@"pointname",
                              pointtime,@"pointtime",
                              pointgroup,@"pointgroup",
                              pointperson,@"pointperson",
                              pointintensity,@"pointintensity",
                              pointcontent,@"pointcontent",
                              upload,@"upload",
                              nil];
        
        BOOL result = [[PointinfoTableHelper sharedInstance]updateDataWith:dict];
        if (!result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            });
        }else{
            
            [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"POINTINFOTAB" Releteid:self.pointinfo.pointid];
            [self saveImages:imgview.dataProvider releteId:pointid releteTable:@"POINTINFOTAB"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view endEditing:YES];
                
                if ([self.delegate respondsToSelector:@selector(updatePointinfoSuccess:)]) {
                    [self.delegate updatePointinfoSuccess:self];
                }
             });
          }
    } completionBlock:^{
        [hud removeFromSuperview];
        //[hud release];
    }];
}

-(NSString *)switchRomeNumToNum:(NSString *)romeNum
{
    NSArray *romes = @[@"Ⅰ",@"Ⅱ",@"Ⅲ",@"Ⅳ",@"Ⅴ",@"Ⅵ",@"Ⅶ",@"Ⅷ",@"Ⅸ",@"Ⅹ",@"Ⅺ",@"Ⅻ"];
    NSUInteger num = [romes indexOfObject:romeNum];
    return [NSString stringWithFormat:@"%d",(int)(num+1)];
}

/**
 *  重写父类方法
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


-(void)reverseGeocodeFailure
{
    [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"无法解析当前地址，您可手动输入地址" delegate:nil
                                   cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
}

-(void)reverseGeocodeSuccess:(NSString *)address
{
    self.pointlocationTextF.text = address;
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
    NSLog(@"PointinfoViewController释放了吗。。。。。。。。。。。。。");
}
@end

