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


@interface PointinfoViewController ()<UIAlertViewDelegate,chooseIntensityDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointidTopCons;        //调查点编号TextField的顶部约束
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointidWidthCons;      //调查点编号TextField的宽约束
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;
    
    [self initPointinfoVC];
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
        self.earthidTextF.text = appDelegate.earthinfo.earthid;
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        self.pointtimeTextF.text = [formatter stringFromDate:date];
        
        _locationHelp = [[LocationHelper alloc] init];
        AppDelegate *appdl = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        self.pointlatTextF.text = [NSString stringWithFormat:@"%f",appdl.currentLocation.coordinate.latitude];
        self.pointlonTextF.text = [NSString stringWithFormat:@"%f",appdl.currentLocation.coordinate.longitude];
        // __weak typeof(self) weakSelf = self;
        [_locationHelp reverseGeocodeWithSuccess:^(NSString *address) {
            self.pointlocationTextF.text = address;
        } failure:^{
            [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"无法解析当前地址，您可手动输入地址" delegate:nil
                              cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
        }];
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
        if ([self.pointinfo.upload isEqualToString:kdidUpload]) {
            self.pointintensityTextF.userInteractionEnabled = YES;
        }else{
            for (UIView *txt in self.textInputViews) {
                txt.userInteractionEnabled = YES;
            }
        }
    }
}

#pragma mark UITextFieldDelegate方法

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [super textFieldShouldBeginEditing:textField];
    BOOL canEdit;
    
    if (textField.tag ==1000 || textField.tag == 1001 ) {
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
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.view endEditing:YES];
                
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

-(void)updateNetWorkPointInfo
{
    MBProgressHUD *mbprogress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSString *pointid = self.pointinfo.pointid;
    NSString *earthid = self.earthidTextF.text;
    NSString *pointlocation = self.pointlocationTextF.text;
    NSString *pointlon = self.pointlonTextF.text;
    NSString *pointlat = self.pointlatTextF.text;
    NSString *pointname = self.pointnameTextF.text;
    NSString *pointtime = self.pointtimeTextF.text;
    NSString *pointgroup = self.pointgroupTextF.text;
    NSString *pointperson = self.pointPersonTextF.text;
    
    NSString * pointintensity0  = self.pointintensityTextF.text;
    NSString * pointintensity  = [self switchRomeNumToNum:self.pointintensityTextF.text];
    
    NSString *pointcontent = self.pointcontentTextV.text;
    NSString *upload = self.pointinfo.upload;

    //创建字典对象作为上传参数
    NSMutableDictionary *parameters1 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        pointid,@"pointid",
                                        earthid,@"earthid",
                                        pointlocation,@"location",
                                        pointlon, @"lon",
                                        pointlat, @"lat",
                                        pointname,@"name",
                                        //model.pointtime,@"pointtime",
                                        pointgroup,@"group",
                                        pointperson,@"person",
                                        pointintensity,@"intensity",
                                        pointcontent,@"content",
                                        //upload,@"upload",
                                        nil];
    
    //创建字典对象作为本地保存
    NSMutableDictionary *parameters2 = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        pointid,@"pointid",
                                        earthid,@"earthid",
                                        pointlocation,@"pointlocation",
                                        pointlon, @"pointlon",
                                        pointlat, @"pointlat",
                                        pointname,@"pointname",
                                        pointtime,@"pointtime",
                                        pointgroup,@"pointgroup",
                                        pointperson,@"pointperson",
                                        pointintensity0,@"pointintensity",
                                        pointcontent,@"pointcontent",
                                        upload,@"upload",
                                        nil];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_updatepoint parameters:parameters1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"数据上传成功: %@", responseObject);
        //上传数据成功则更新本地数
        BOOL result = [[PointinfoTableHelper sharedInstance]updateDataWith:parameters2];
        if (result) {
            self.actionType = kActionTypeShow;
        }
        [mbprogress removeFromSuperview];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"数据上传失败:%@",error);
        [mbprogress removeFromSuperview];
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

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc
{
    NSLog(@"PointinfoViewController释放了吗。。。。。。。。。。。。。");
}
@end

