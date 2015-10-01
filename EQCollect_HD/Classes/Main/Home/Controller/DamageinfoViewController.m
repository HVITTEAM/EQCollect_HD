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

@interface DamageinfoViewController ()
{
    CGFloat _navHeight;              // 导航栏与状态栏总的高度
}
@end

@implementation DamageinfoViewController
{
    ImageCollectionView *imgview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //将rootScrollView，containerView 赋值给父类的变量
    self.rootScrollV = self.rootScrollView;
    self.containerV = self.containerView;

    [self initDamageinfo];
    [self initImageCollectionView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self showDamageinfoData];
    if (imgview.showType == kActionTypeShow) {
        [self getimage];
    }
    imgview.nav = self.navigationController;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/**
 *  初始化房屋震害信息控制器
 */
-(void)initDamageinfo
{
    self.navigationItem.title = @"房屋震害";
    
    //默认有状态栏，高度为64
    _navHeight = kNormalNavHeight;
    
    UIBarButtonItem *rigthItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemTap:)];
    self.navigationItem.rightBarButtonItem = rigthItem;

    if (self.actionType == kActionTypeAdd) {
        //设置导航栏按钮
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
                            self.damageidTextF,
                            self.damagetimeTextF,
                            self.zrcorxqTextF,
                            self.dworzhTextF,
                            self.fortificationintensityTextF,
                            self.damageintensityTextF,
                            self.damagesituationTextF,
                            self.damageindexTextF,
                            self.damageaddressTextF
                            ];
    for (int i = 0;i<self.textInputViews.count;i++) {
        UITextField *textF = self.textInputViews[i];
        textF.delegate = self;
        //设置tag
        textF.tag = 1000+i;
    }

    self.intensityItems = @[@"1级",@"2级",@"3级",@"4级",@"5级",@"6级",@"7级",@"8级",@"9级",@"10级"];
    self.fortificationintensityItems = @[@"1级",@"2级",@"3级",@"4级",@"5级",@"6级",@"7级",@"8级",@"9级",@"10级"];
    self.damagesituationItems = @[@"严重",@"中等",@"轻微"];
    self.damageindexItems = @[@"1级",@"2级",@"3级",@"4级",@"5级",@"6级",@"7级",@"8级",@"9级",@"10级"];
    
    [self setActionType:self.actionType];
}

-(void)initImageCollectionView
{
    //创建图片视图
    UICollectionViewFlowLayout *flowLayout =[[UICollectionViewFlowLayout alloc]init];
    imgview = [[ImageCollectionView alloc] initWithCollectionViewLayout:flowLayout];

    if (self.actionType == kActionTypeShow ) {
        imgview.showType= kActionTypeShow;
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
                                @"damageaddressTextF":self.damageaddressTextF,
                                @"imgview":imgview.collectionView,
                                };
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    [self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[damageaddressTextF]-20-[imgview]-20-|" options:0 metrics:nil views:dictViews]];
    self.imgViewHeightCons = [NSLayoutConstraint constraintWithItem:imgview.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:77];
    [imgview.collectionView addConstraint:self.imgViewHeightCons];
}

-(void)showDamageinfoData
{
    if (self.actionType == kActionTypeShow || self.actionType == kactionTypeEdit) {
        //self.damageidTextF.text = self.damageinfo.damageid;
        self.damagetimeTextF.text = self.damageinfo.damagetime;
        self.damageaddressTextF.text = self.damageinfo.damageaddress;
        self.damageintensityTextF.text = self.damageinfo.damageintensity;
        self.zrcorxqTextF.text = self.damageinfo.zrcorxq;
        self.dworzhTextF.text = self.damageinfo.dworzh;
        self.fortificationintensityTextF.text = self.damageinfo.fortificationintensity;
        self.damagesituationTextF.text = self.damageinfo.damagesituation;
        self.damageindexTextF.text = self.damageinfo.damageindex;
    }else {
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        self.damagetimeTextF.text = [formatter stringFromDate:date];
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

    if(UIInterfaceOrientationIsLandscape(interfaceOrientation)&& self.actionType == kActionTypeShow)
    {
        //设备为横屏且不是新增界面，设置为横屏约束
        self.damageidWidthCons.constant = 180;
    }else{
        //设备为竖屏或新增界面，设置为竖屏约束
        self.damageidWidthCons.constant = 100;
    }
    self.damageidTopCons.constant = 20+_navHeight;
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
            [self showAlertViewWithTextField:textField items:self.intensityItems];
            break;
        case 1005:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.fortificationintensityItems];
            break;
        case 1006:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.damagesituationItems];
            break;
        case 1007:
            canEdit = NO;
            [self showAlertViewWithTextField:textField items:self.damageindexItems];
            break;
        default:
            canEdit = YES;
            break;
    }
    return canEdit;
}

/**
 *  新增房屋震害信息
 */
-(void)addDamageinfo
{
    NSString *damageid = self.damageidTextF.text;
    NSString *damagetime = self.damagetimeTextF.text;
    NSString *damageaddress = self.damageaddressTextF.text;
    NSString *damageintensity = self.damageintensityTextF.text;
    NSString *zrcorxq = self.zrcorxqTextF.text;
    NSString *dworzh = self.dworzhTextF.text;
    NSString *fortificationintensity = self.fortificationintensityTextF.text;
    NSString *damagesituation = self.damagesituationTextF.text;
    NSString *damageindex = self.damageindexTextF.text;
    
    
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
                          damageid,@"damageid",
                          damagetime,@"damagetime",
                          damageaddress,@"damageaddress",
                          damageintensity, @"damageintensity",
                          zrcorxq, @"zrcorxq",
                          dworzh,@"dworzh",
                          fortificationintensity,@"fortificationintensity",
                          damagesituation,@"damagesituation",
                          damageindex,@"damageindex",
                          self.pointid,@"pointid",
                          @"0",@"upload",
                          nil];
    
    BOOL result = [[DamageinfoTableHelper sharedInstance] insertDataWith:dict];
    if (!result) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错,请确定编号唯一" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{
        self.damageidTextF.text = nil;
        self.damagetimeTextF.text = nil;
        self.damageaddressTextF.text = nil;
        self.damageintensityTextF.text = nil;
        self.zrcorxqTextF.text = nil;
        self.dworzhTextF.text = nil;
        self.fortificationintensityTextF.text = nil;
        self.damagesituationTextF.text = nil;
        self.damageindexTextF.text = nil;

        [[NSNotificationCenter defaultCenter] postNotificationName:kAddDamageinfoSucceedNotification object:nil];
        NSInteger maxid=[[DamageinfoTableHelper sharedInstance] getMaxIdOfRecords];
        if (maxid!=0 ) {
           
            [self saveImagesWithReleteId:[NSString stringWithFormat:@"%ld",(long)maxid] releteTable:@"DAMAGEINFOTAB"];
        }
    }
    //清空imageCollectionView的数据
    imgview.dataProvider = [[NSMutableArray alloc] init];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)back
{
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
    NSLog(@"%d",imgview.dataProvider.count);
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
                NSLog(@"success to writeFile");
                NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                      v.name,@"pictureName",
                                      filePath,@"picturePath",
                                      releteID,@"releteid",
                                      releteTable,@"reletetable",
                                      nil];
                NSLog(@"%@",filePath);
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
    NSMutableArray * imageArr= [[PictureInfoTableHelper sharedInstance] selectDataByReleteTable:@"DAMAGEINFOTAB" Releteid:self.damageinfo.damageid];
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
        NSLog(@"%@",vo.name);
    }
    //imgview.showType = YES;

    imgview.dataProvider = dataProvider;
}




-(void)rightItemTap:(UIBarButtonItem *)sender
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        self.actionType = kactionTypeEdit;
        self.navigationItem.rightBarButtonItem.title = @"确定";
    }else{
        if (self.actionType == kActionTypeAdd) {
            [self addDamageinfo];
        }else{
            [self updateAbnormalinfo];
            [self.view endEditing:YES];
            self.actionType = kActionTypeShow;
            self.navigationItem.rightBarButtonItem.title = @"编辑";
        }
    }
}

-(void)updateAbnormalinfo
{
   // NSString *damageid = self.damageidTextF.text;
    NSString *damagetime = self.damagetimeTextF.text;
    NSString *damageaddress = self.damageaddressTextF.text;
    NSString *damageintensity = self.damageintensityTextF.text;
    NSString *zrcorxq = self.zrcorxqTextF.text;
    NSString *dworzh = self.dworzhTextF.text;
    NSString *fortificationintensity = self.fortificationintensityTextF.text;
    NSString *damagesituation = self.damagesituationTextF.text;
    NSString *damageindex = self.damageindexTextF.text;
    
    
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
                          self.damageinfo.damageid,@"damageid",
                          damagetime,@"damagetime",
                          damageaddress,@"damageaddress",
                          damageintensity, @"damageintensity",
                          zrcorxq, @"zrcorxq",
                          dworzh,@"dworzh",
                          fortificationintensity,@"fortificationintensity",
                          damagesituation,@"damagesituation",
                          damageindex,@"damageindex",
                          self.damageinfo.pointid,@"pointid",
                          self.damageinfo.upload,@"upload",
                          nil];
    
    BOOL result = [[DamageinfoTableHelper sharedInstance] updateDataWith:dict];
    if (!result) {
        [[[UIAlertView alloc] initWithTitle:nil message:@"新建数据出错,请确定编号唯一" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil] show];
    }else{
        [self.view endEditing:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddDamageinfoSucceedNotification object:nil];
        
        for (id vo in imgview.dataProvider)
        {
            if ([vo isKindOfClass:[PictureVO class]]){
            [[PictureInfoTableHelper sharedInstance] deleteDataByAttribute:@"pictureName" value:((PictureVO *)vo).name];
            }
        }
        [self saveImagesWithReleteId:self.damageinfo.damageid releteTable:@"DAMAGEINFOTAB"];
    }
}


@end
