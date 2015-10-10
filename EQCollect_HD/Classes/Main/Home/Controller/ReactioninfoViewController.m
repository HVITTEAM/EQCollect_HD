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

@interface ReactioninfoViewController ()
{
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
}
@end

@implementation ReactioninfoViewController
{
    ImageCollectionView *imgview;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;
    
    [self initReactioninfoVC];
    [self initImageCollectionView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showReactioninfoData];
    if (imgview.showType == kActionTypeShow ) {
        [self getimage];
    }
    imgview.nav = self.navigationController;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/**
 *  初始化人物反应信息控制器
 */
-(void)initReactioninfoVC
{
    self.navigationItem.title = @"人物反应";
    
    //默认有状态栏，高度为64
    _navHeight = kNormalNavHeight;
    
    UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemTap:)];
    self.navigationItem.rightBarButtonItem = rigthItem;

    if (self.actionType == kActionTypeAdd) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        self.navigationItem.leftBarButtonItem = leftItem;
        
        rigthItem.title = @"确定";
        
        //当为新增时没有状态栏，高度为44
        _navHeight = kAddNavheight;
        //启用交互
        [self.view setUserInteractionEnabled:YES];
    }
    //获取设备当前方向
    UIDeviceOrientation devOrientation = [[UIDevice currentDevice] orientation];
    //将UIDeviceOrientation类型转为UIInterfaceOrientation
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)devOrientation;
    //根据屏幕方向设置视图的约束
    [self rotationToInterfaceOrientation:interfaceOrientation];
    
    self.textInputViews = @[
                            self.reactionidTextF,
                            self.reactiontimeTextF,
                            self.informantnameTextF,
                            self.informantageTextF,
                            self.informanteducationTextF,
                            self.informantjobTextF,
                            self.reactionaddressTextF,
                            self.rockfeelingTextF,
                            self.throwfeelingTextF,
                            self.throwtingsTextF,
                            self.throwdistanceTextF,
                            self.fallTextF,
                            self.hangTextF,
                            self.furnituresoundTextF,
                            self.furnituredumpTextF,
                            self.soundsizeTextF,
                            self.sounddirectionTextF
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
    
    [self setActionType:self.actionType];
}


-(void)initImageCollectionView
{
    //创建图片视图
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc]init];
    imgview = [[ImageCollectionView alloc] initWithCollectionViewLayout:flowLayout];
    imgview.nav = self.navigationController;
    
    if (self.actionType == kActionTypeShow ) {
        imgview.showType = kActionTypeShow;
    }else if (self.actionType == kactionTypeEdit){
        imgview.showType = kactionTypeEdit;
    }else
        imgview.showType = kActionTypeAdd;
    
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
                                @"sounddirectionTextF":self.sounddirectionTextF,
                                @"imgview":imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[sounddirectionTextF]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    self.imgViewHeightCons = [NSLayoutConstraint constraintWithItem:imgview.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:87];
    [imgview.collectionView addConstraint:self.imgViewHeightCons];
}


-(void)showReactioninfoData
{
    if (self.actionType == kActionTypeShow || self.actionType == kactionTypeEdit) {
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
        
    }else {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        self.reactiontimeTextF.text = [formatter stringFromDate:date];
    }
}

-(void)setActionType:(ActionType)actionType
{
    _actionType = actionType;
    if (actionType == kActionTypeShow) {
        for (UITextField *txt in self.textInputViews) {
            txt.userInteractionEnabled = NO;
        }
    }
    if (actionType == kActionTypeAdd || actionType == kactionTypeEdit) {
        for (UITextField *txt in self.textInputViews) {
            txt.userInteractionEnabled = YES;
        }
    }
    
    if (self.actionType == kActionTypeShow ) {
        imgview.showType= kActionTypeShow;
    }else if (self.actionType == kactionTypeEdit){
        imgview.showType = kactionTypeEdit;
    }else
        imgview.showType = kActionTypeAdd;
}

//处理屏幕旋转
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self rotationToInterfaceOrientation:interfaceOrientation];
}

/**
 *  旋转屏幕时更改约束
 *
 *  @param interfaceOrientation 要旋转的方向
 */
-(void)rotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(UIInterfaceOrientationIsLandscape(interfaceOrientation) && self.actionType==kActionTypeShow)
    {
        //设备为横屏且不是新增界面，设置为横屏约束
        self.reactionidWidthCons.constant = 180;
    }else{
        //设备为竖屏或新增界面，设置为竖屏约束
        self.reactionidWidthCons.constant = 100;
    }
    self.reactionidTopCons.constant = 20+_navHeight;
    //更新约束
    [self.view updateConstraintsIfNeeded];
}


#pragma mark UITextFieldDelegate方法
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [super textFieldShouldBeginEditing:textField];
    BOOL canEdit;
    //根据文本框的tag来确定哪些允许手动输入，哪些需要弹出框来选择
    switch (textField.tag) {
        case 1001:
            canEdit = NO;
            break;
        case 1004:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.educationItems];
            break;
        case 1007:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.rockfeelingItems];
            break;
        case 1008:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.throwfeelingItems];
            break;
        case 1009:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.throwtingsItems];
            break;
        case 1011:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.fallItems];
            break;
        case 1012:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.hangItems];
            break;
        case 1013:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.furnituresoundItems];
            break;
        case 1015:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.soundsizeItems];
            break;
        case 1016:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.sounddirectionItems];
            break;
        default:
            canEdit = YES;
            break;
    }
    return canEdit;
}

-(void)addReactioninfo
{
    //NSString *reactionid = self.reactionidTextF.text;
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
   
    
    //判断文本输入框是否为空，如果为空则提示并返回
    for (int i=0; i<self.textInputViews.count; i++) {
        UITextField *textF = (UITextField *)self.textInputViews[i];
        if (textF.text ==nil || textF.text.length <=0) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"所填项目不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            return;
        }
    }
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          //reactionid,@"reactionid",
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
                          @"0",@"upload",
                          nil];
    
    BOOL result = [[ReactioninfoTableHelper sharedInstance] insertDataWith:dict];
    if (!result) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{
        
        NSInteger maxid=[[ReactioninfoTableHelper sharedInstance] getMaxIdOfRecords];
        if (maxid!=0 ) {
            [self saveImagesWithReleteId:[NSString stringWithFormat:@"%ld",(long)maxid] releteTable:@"REACTIONINFOTAB"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //self.reactionidTextF.text = nil;
            self.reactiontimeTextF.text = nil;
            self.informantnameTextF.text = nil;
            self.informantageTextF.text = nil;
            self.informanteducationTextF.text = nil;
            self.informantjobTextF.text = nil;
            self.reactionaddressTextF.text = nil;
            self.rockfeelingTextF.text = nil;
            self.throwfeelingTextF.text = nil;
            self.throwtingsTextF.text = nil;
            self.throwdistanceTextF.text = nil;
            self.fallTextF.text = nil;
            self.hangTextF.text = nil;
            self.furnituresoundTextF.text = nil;
            self.furnituredumpTextF.text = nil;
            self.soundsizeTextF.text = nil;
            self.sounddirectionTextF.text = nil;
            
            [self.view endEditing:YES];
            //清空imageCollectionView的数据
            imgview.dataProvider = [[NSMutableArray alloc] init];
            [self dismissViewControllerAnimated:YES completion:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAddReactioninfoSucceedNotification object:nil];
        });
    }
}

-(void)back
{
    //清空imageCollectionView的数据
    imgview.dataProvider = [[NSMutableArray alloc] init];
    [self dismissViewControllerAnimated:YES completion:nil];
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
 * 保存图片
 **/
-(void)saveImagesWithReleteId:(NSString *)releteID releteTable:(NSString *)releteTable
{
    //保存图片
    for (int i = 0; i < imgview.dataProvider.count ; i++)
    {
        if ([imgview.dataProvider[i] isKindOfClass:[PictureVO class]])
        {
            PictureVO *v = (PictureVO*)imgview.dataProvider[i];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
            NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", v.name]];
            BOOL result = [UIImagePNGRepresentation(v.image)writeToFile: filePath    atomically:YES];  // 写入本地沙盒
            if (result)
            {
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      v.name,@"pictureName",
                                      filePath,@"picturePath",
                                      releteID,@"releteid",
                                      releteTable,@"reletetable",
                                      nil];
                //保存数据库
                [[PictureInfoTableHelper sharedInstance] insertDataWith:dict];
            }
        }
    }
}

/**
 * 获取图片
 **/
-(void)getimage
{
    NSMutableArray *dataProvider = [[NSMutableArray alloc] init];
    NSMutableArray * imageArr= [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:@"REACTIONINFOTAB" Releteid:self.reactioninfo.reactionid];
    //循环添加图片
    for(PictureMode* pic in imageArr)
    {
        PictureVO *vo = [[PictureVO alloc] init];
        vo.name = pic.pictureName;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", pic.pictureName]];
        UIImage *img = [UIImage imageWithContentsOfFile:filePath];
        vo.image = img;
        [dataProvider addObject:vo];
    }
    imgview.dataProvider = dataProvider;
}


-(void)rightItemTap:(UIBarButtonItem *)sender
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        self.actionType = kactionTypeEdit;
        self.navigationItem.rightBarButtonItem.title = @"确定";
    }else{
        if (self.actionType == kActionTypeAdd) {
            [self showMBProgressHUDWithSel:@selector(addReactioninfo)];
            //[self addReactioninfo];
        }else{
            [self showMBProgressHUDWithSel:@selector(updateReactioninfo)];
            //[self updateAbnormalinfo];
            [self.view endEditing:YES];
            self.actionType = kActionTypeShow;
            self.navigationItem.rightBarButtonItem.title = @"编辑";
        }
    }
}

-(void)updateReactioninfo
{
    //NSString *reactionid = self.reactionidTextF.text;
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
    
    
    //判断文本输入框是否为空，如果为空则提示并返回
    for (int i=0; i<self.textInputViews.count; i++) {
        UITextField *textF = (UITextField *)self.textInputViews[i];
        if (textF.text ==nil || textF.text.length <=0) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"所填项目不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
            return;
        }
    }
    //创建字典对象并向表中插和数据
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          self.reactioninfo.reactionid,@"reactionid",
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
                          self.reactioninfo.pointid,@"pointid",
                          nil];
    
    BOOL result = [[ReactioninfoTableHelper sharedInstance] updateDataWith:dict];
    if (!result) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"更新数据出错" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{

        //[[NSNotificationCenter defaultCenter] postNotificationName:kAddReactioninfoSucceedNotification object:nil];
        [[PictureInfoTableHelper sharedInstance] deleteDataByReleteTable:@"REACTIONINFOTAB" Releteid:self.reactioninfo.reactionid];
        [self saveImagesWithReleteId:self.reactioninfo.reactionid releteTable:@"REACTIONINFOTAB"];
    }


}


@end
