//
//  ReactioninfoViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/9/8.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
#define kNormalNavHeight 64
#define kAddNavheight 44
#import "ReactioninfoViewController.h"
#import "ImageCollectionView.h"
#import "PictureMode.h"

@interface ReactioninfoViewController ()<UIAlertViewDelegate>
{
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
    UIBarButtonItem *_rigthItem;      //导航栏右侧按钮
    ImageCollectionView *imgview;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionidTopCons;        //人物反应编号TextField的顶部约束
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reactionidWidthCons;     //人物反应编号TextField宽约束
@property (strong,nonatomic) NSLayoutConstraint *imgViewHeightCons;  //图片View的高约束
@property (weak, nonatomic) IBOutlet UIScrollView *rootScrollView;  //用于滚动的scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;         //包裹真正内容的容器view

@property (weak, nonatomic) IBOutlet UITextField *reactionidTextF;                //人物反应编号
@property (weak, nonatomic) IBOutlet UITextField *reactiontimeTextF;              //调查时间
@property (weak, nonatomic) IBOutlet UITextField *informantnameTextF;             //被调查者姓名
@property (weak, nonatomic) IBOutlet UITextField *informantageTextF;              //被调查者年龄
@property (weak, nonatomic) IBOutlet UITextField *informanteducationTextF;        //被调查者学历
@property (weak, nonatomic) IBOutlet UITextField *informantjobTextF;              //被调查者职业
@property (weak, nonatomic) IBOutlet UITextField *reactionaddressTextF;           //所在地
@property (weak, nonatomic) IBOutlet UITextField *rockfeelingTextF;               //晃动感觉
@property (weak, nonatomic) IBOutlet UITextField *throwfeelingTextF;              //抛起感觉
@property (weak, nonatomic) IBOutlet UITextField *throwtingsTextF;                //抛弃物
@property (weak, nonatomic) IBOutlet UITextField *throwdistanceTextF;             //抛起距离
@property (weak, nonatomic) IBOutlet UITextField *fallTextF;                      //搁置物滚落
@property (weak, nonatomic) IBOutlet UITextField *hangTextF;                      //悬挂物
@property (weak, nonatomic) IBOutlet UITextField *furnituresoundTextF;            //家具声响
@property (weak, nonatomic) IBOutlet UITextField *furnituredumpTextF;             //家具倾倒
@property (weak, nonatomic) IBOutlet UITextField *soundsizeTextF;                 //地声大小
@property (weak, nonatomic) IBOutlet UITextField *sounddirectionTextF;            //地声方向

@property (strong,nonatomic)NSArray *textInputViews;           //所有的文本输入框
@property (strong,nonatomic)NSArray *educationItems;           //学历选项
@property (strong,nonatomic)NSArray *rockfeelingItems;         //晃动感觉选项
@property (strong,nonatomic)NSArray *throwfeelingItems;        //抛起感觉选项
@property (strong,nonatomic)NSArray *throwtingsItems;          //抛弃物选项
@property (strong,nonatomic)NSArray *fallItems;                //搁置物滚落选项
@property (strong,nonatomic)NSArray *hangItems;                //悬挂物选项
@property (strong,nonatomic)NSArray *furnituresoundItems;      //家具声响选项
@property (strong,nonatomic)NSArray *soundsizeItems;           //地声大小选项
@property (strong,nonatomic)NSArray *sounddirectionItems;      //地声方向选项

@end

@implementation ReactioninfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;
    
    [self initReactioninfoVC];
    [self initImageCollectionView];
    [self showReactioninfoData];
}

/**
 *  初始化人物反应信息控制器
 */
-(void)initReactioninfoVC
{
    self.navigationItem.title = @"人物反应";
    
    //默认有状态栏，高度为64
    _navHeight = kNormalNavHeight;
    
    _rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemTap:)];
    if ([self.reactioninfo.upload isEqualToString:kdidNotUpload]) {
        self.navigationItem.rightBarButtonItem = _rigthItem;
    }

    if (self.actionType == kActionTypeAdd) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        
        _rigthItem.title = @"确定";
         self.navigationItem.rightBarButtonItem = _rigthItem;
        
        //当为新增时没有状态栏，高度为44
        _navHeight = kAddNavheight;
        //启用交互
        [self.view setUserInteractionEnabled:YES];
    }
    self.textInputViews = @[
                            self.reactionidTextF,
                            self.reactiontimeTextF,
                            self.informantnameTextF,
                            self.informantageTextF,
                            self.informanteducationTextF,
                            self.informantjobTextF,
                            self.rockfeelingTextF,
                            self.throwfeelingTextF,
                            self.throwdistanceTextF,
                            self.throwtingsTextF,
                            self.hangTextF,
                            self.fallTextF,
                            self.furnituredumpTextF,
                            self.furnituresoundTextF,
                            self.sounddirectionTextF,
                            self.soundsizeTextF,
                            self.reactionaddressTextF
                            ];
    for (int i = 0;i<self.textInputViews.count;i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }

    self.educationItems = @[@"博士",@"研究生",@"大学",@"中学",@"小学",@"其它"];
    self.rockfeelingItems =@[@"强烈",@"中等",@"微弱",@"无感觉"];
    self.throwfeelingItems = @[@"强烈",@"中等",@"微弱",@"无感觉"];
    self.throwtingsItems = @[@"砖石块",@"茶杯",@"水壶",@"小家具",@"其它"];
    self.fallItems = @[@"少量",@"部分",@"多数",@"全部"];
    self.hangItems = @[@"电灯摆动",@"墙上挂画,乐器,小型家俱掉下来"];
    self.furnituresoundItems = @[@"轻微",@"较响",@"剧烈"];
    self.soundsizeItems = @[@"强烈",@"中等",@"微弱",@"无地声"];
    self.sounddirectionItems = @[@"东",@"南",@"西",@"北",@"东南",@"西北",@"西南",@"东北"];
    
    //设置顶部高约束
    self.reactionidTopCons.constant = 20+_navHeight;
    
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
                                @"reactionaddressTextF":self.reactionaddressTextF,
                                @"imgview":imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[reactionaddressTextF]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    self.imgViewHeightCons = [NSLayoutConstraint constraintWithItem:imgview.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:87];
    [imgview.collectionView addConstraint:self.imgViewHeightCons];
}

/**
 *  显示数据
 */
-(void)showReactioninfoData
{
    if (self.actionType == kActionTypeShow || self.actionType == kactionTypeEdit) {
        self.reactionidTextF.text = self.reactioninfo.reactionid;
        self.reactiontimeTextF.text= self.reactioninfo.reactiontime;
        self.informantnameTextF.text= self.reactioninfo.informantname;
        self.informantageTextF.text= self.reactioninfo.informantage;
        self.informanteducationTextF.text= self.reactioninfo.informanteducation;
        self.informantjobTextF.text= self.reactioninfo.informantjob;
        self.reactionaddressTextF.text= self.reactioninfo.reactionaddress;
        self.rockfeelingTextF.text= self.reactioninfo.rockfeeling;
        self.throwfeelingTextF.text= self.reactioninfo.throwfeeling;
        self.throwtingsTextF.text= self.reactioninfo.throwtings;
        self.throwdistanceTextF.text= self.reactioninfo.throwdistance;
        self.fallTextF.text= self.reactioninfo.fall;
        self.hangTextF.text= self.reactioninfo.hang;
        self.furnituresoundTextF.text= self.reactioninfo.furnituresound;
        self.furnituredumpTextF.text= self.reactioninfo.furnituredump;
        self.soundsizeTextF.text= self.reactioninfo.soundsize;
        self.sounddirectionTextF.text= self.reactioninfo.sounddirection;
        
        //[self getimage];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *images = [self getImagesWithReleteId:self.reactioninfo.reactionid releteTable:@"REACTIONINFOTAB"];
            dispatch_async(dispatch_get_main_queue(), ^{
                imgview.dataProvider = images;
            });
        });
    }else {
        
        self.reactionidTextF.text = [self createUniqueIdWithAbbreTableName:@"FY"];
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        self.reactiontimeTextF.text = [formatter stringFromDate:date];
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
        for (UITextField *txt in self.textInputViews) {
            txt.userInteractionEnabled = YES;
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
    switch (textField.tag) {
        case 1000:
        case 1001:
            canEdit = NO;
            break;
        case 1004:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.educationItems];
            break;
        case 1006:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.rockfeelingItems];
            break;
        case 1007:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.throwfeelingItems];
            break;
        case 1009:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.throwtingsItems];
            break;
        case 1010:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.hangItems];
            break;
        case 1011:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.fallItems];
            break;
        case 1013:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.furnituresoundItems];
            break;
        case 1014:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.sounddirectionItems];
            break;
        case 1015:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.soundsizeItems];
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
    if (self.actionType == kActionTypeShow) {
        self.navigationItem.rightBarButtonItem.title = @"确定";
        self.actionType = kactionTypeEdit;
    }else if(self.actionType == kActionTypeAdd){
        if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
            [self showMBProgressHUDWithSel:@selector(addReactioninfo)];
        }
    }else{
        if (![self hasTextBeNullInTextInputViews:self.textInputViews]) {
            [self showMBProgressHUDWithSel:@selector(updateReactioninfo)];
            //[self.view endEditing:YES];
            self.navigationItem.rightBarButtonItem.title = @"编辑";
            self.actionType = kActionTypeShow;
        }
    }
}

/**
 * 新增人物反应
 **/
-(void)addReactioninfo
{
    //防止异步加载图片出错
    imgview.isExitThread = YES;

    NSString *reactionid = self.reactionidTextF.text;
    NSString *reactiontime = self.reactiontimeTextF.text;
    NSString *informantname = self.informantnameTextF.text;
    NSString *informantage = self.informantageTextF.text;
    NSString *informanteducation = self.informanteducationTextF.text;
    NSString *informantjob = self.informantjobTextF.text;
    NSString *reactionaddress = self.reactionaddressTextF.text;
    NSString *rockfeeling = self.rockfeelingTextF.text;
    NSString *throwfeeling = self.throwfeelingTextF.text;
    NSString *throwtings = self.throwtingsTextF.text;
    NSString *throwdistance = self.throwdistanceTextF.text;
    NSString *fall = self.fallTextF.text;
    NSString *hang = self.hangTextF.text;
    NSString *furnituresound = self.furnituresoundTextF.text;
    NSString *furnituredump = self.furnituredumpTextF.text;
    NSString *soundsize = self.soundsizeTextF.text;
    NSString *sounddirection = self.sounddirectionTextF.text;
    
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          reactionid,@"reactionid",
                          reactiontime,@"reactiontime",
                          informantname,@"informantname",
                          informantage, @"informantage",
                          informanteducation, @"informanteducation",
                          informantjob,@"informantjob",
                          reactionaddress,@"reactionaddress",
                          rockfeeling,@"rockfeeling",
                          throwfeeling,@"throwfeeling",
                          throwtings,@"throwtings",
                          throwdistance,@"throwdistance",
                          fall,@"fall",
                          hang,@"hang",
                          furnituresound,@"furnituresound",
                          furnituredump,@"furnituredump",
                          soundsize,@"soundsize",
                          sounddirection,@"sounddirection",
                          self.pointid,@"pointid",
                          kdidNotUpload,@"upload",
                          nil];
    
    BOOL result = [[ReactioninfoTableHelper sharedInstance] insertDataWith:dict];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        
        //[self saveImagesWithReleteId:reactionid releteTable:@"REACTIONINFOTAB"];
        [self saveImages:imgview.dataProvider releteId:reactionid releteTable:@"REACTIONINFOTAB"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            //清空imageCollectionView的数据
            imgview.dataProvider = [[NSMutableArray alloc] init];
            //防止循环引用导致无法释放当前这个控制器
            imgview.nav = nil;
            if ([self.delegate respondsToSelector:@selector(addReactioninfoSuccess:)]) {
                [self.delegate addReactioninfoSuccess:self];
            }
        });
    }
}

/**
 * 更新人物反应
 **/
-(void)updateReactioninfo
{
    //防止异步加载图片出错
    imgview.isExitThread = YES;

    //NSString *reactionid = self.reactionidTextF.text;
    //NSString *reactiontime = self.reactiontimeTextF.text;
    NSString *informantname = self.informantnameTextF.text;
    NSString *informantage = self.informantageTextF.text;
    NSString *informanteducation = self.informanteducationTextF.text;
    NSString *informantjob = self.informantjobTextF.text;
    NSString *reactionaddress = self.reactionaddressTextF.text;
    NSString *rockfeeling = self.rockfeelingTextF.text;
    NSString *throwfeeling = self.throwfeelingTextF.text;
    NSString *throwtings = self.throwtingsTextF.text;
    NSString *throwdistance = self.throwdistanceTextF.text;
    NSString *fall = self.fallTextF.text;
    NSString *hang = self.hangTextF.text;
    NSString *furnituresound = self.furnituresoundTextF.text;
    NSString *furnituredump = self.furnituredumpTextF.text;
    NSString *soundsize = self.soundsizeTextF.text;
    NSString *sounddirection = self.sounddirectionTextF.text;

    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.reactioninfo.reactionid,@"reactionid",
                          self.reactioninfo.reactiontime,@"reactiontime",
                          informantname,@"informantname",
                          informantage, @"informantage",
                          informanteducation, @"informanteducation",
                          informantjob,@"informantjob",
                          reactionaddress,@"reactionaddress",
                          rockfeeling,@"rockfeeling",
                          throwfeeling,@"throwfeeling",
                          throwtings,@"throwtings",
                          throwdistance,@"throwdistance",
                          fall,@"fall",
                          hang,@"hang",
                          furnituresound,@"furnituresound",
                          furnituredump,@"furnituredump",
                          soundsize,@"soundsize",
                          sounddirection,@"sounddirection",
                          self.reactioninfo.pointid,@"pointid",
                          self.reactioninfo.upload,@"upload",
                          nil];
    
    BOOL result = [[ReactioninfoTableHelper sharedInstance] updateDataWith:dict];
    if (!result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
        });
    }else{
        [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"REACTIONINFOTAB" Releteid:self.reactioninfo.reactionid];
        //[self saveImagesWithReleteId:self.reactioninfo.reactionid releteTable:@"REACTIONINFOTAB"];
        [self saveImages:imgview.dataProvider releteId:self.reactioninfo.reactionid releteTable:@"REACTIONINFOTAB"];

        if ([self.delegate respondsToSelector:@selector(updateReactioninfoSuccess:)]) {
            [self.delegate updateReactioninfoSuccess:self];
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
    NSLog(@"ReactioninfoViewController 释放了吗");
}
@end
