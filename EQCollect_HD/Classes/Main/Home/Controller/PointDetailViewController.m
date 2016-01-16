//
//  PointDetailViewController.m
//  EQCollect_HD
//
//  Created by shi on 15/12/29.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "PointDetailViewController.h"

#import "AbnormalinfoListController.h"
#import "ReactioninfoListController.h"
#import "DamageinfoListController.h"

#import "PointinfoViewController.h"
#import "AbnormalinfoViewController.h"
#import "ReactioninfoViewController.h"
#import "DamageinfoViewController.h"
#import "OtherListViewController.h"
#import "OtherViewController.h"

static const CGFloat kHeightOfNaviBar = 64.0f;
static const CGFloat kHeightOfTopScrollView = 44.0f;
static const CGFloat kWidthOfButtonMargin = 16.0f;
static const CGFloat kFontSizeOfTabButton = 17.0f;

//当前显示的是什么页面
typedef NS_ENUM(NSInteger, PageType) {
    kPageTypePoint,
    kPageTypeDamage,
    kPageTypeReaction,
    kPageTypeOther,
    kPageTypeAbnormal,
};

@interface PointDetailViewController ()<UIScrollViewDelegate>

@property(strong,nonatomic)UIScrollView *titleScrollView;                           //上部的 scrollView

@property(strong,nonatomic)UIScrollView *contentScrollView;                         //下部的 scrollView

@property(strong,nonatomic)NSMutableArray *titleBtns;                               //标题按钮数组

@property(strong,nonatomic)UIButton *selectedBtn;                                   //被选中的按钮

@property(strong,nonatomic)UIImageView *bottomLine;                                 //上部的scrollView中的指示条

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@property(strong,nonatomic)UIBarButtonItem *rightItem;       //导航条右侧按钮

@property(assign,nonatomic)PageType currentPage;        //当前页面类型

@end

@implementation PointDetailViewController

#pragma mark -- 生命周期方法 --

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = HMGlobalBg;
    
    [self initSubView];
    
    [self initPointDetail];
    
    [self createrTitleButton];
    
    [self initNaviBar];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat rootViewWidth = self.view.bounds.size.width;
    CGFloat rootViewHeight = self.view.bounds.size.height;
    
    //设置顶部ScrollView和下面内容ScrollView的 Frame
    self.titleScrollView.frame = CGRectMake(0,kHeightOfNaviBar, rootViewWidth, kHeightOfTopScrollView);
    self.contentScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.titleScrollView.frame), rootViewWidth, rootViewHeight - kHeightOfNaviBar - kHeightOfTopScrollView);
    
    //设置contentSize
    self.contentScrollView.contentSize = CGSizeMake(rootViewWidth * self.childViewControllers.count, self.contentScrollView.bounds.size.height);
    
    //设置子类视图控制器的 View的 frame
    for (int i = 0; i < self.childViewControllers.count; i++) {
        UIViewController *vc = self.childViewControllers[i];
        vc.view.frame = CGRectMake(i * rootViewWidth, 0, rootViewWidth, self.contentScrollView.bounds.size.height);
    }
    
    [self layoutTitleBtn];
}

#pragma mark -- getter 和 setter方法 --
-(NSMutableArray *)titleBtns
{
    if (!_titleBtns) {
        _titleBtns = [[NSMutableArray alloc] init];
    }
    return _titleBtns;
}

#pragma mark -- 初始化设置方法 --

-(void)initNaviBar
{
    self.title = @"调查点详情";
    
    self.rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rigthItemTap:)];
    
    if ([self.pointinfo.upload isEqualToString:kdidNotUpload]) {
        self.navigationItem.rightBarButtonItem = self.rightItem;
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //设置当前页面
    self.currentPage = kPageTypePoint;
}

/**
 *  初始化上下两个ScrollView
 */
-(void)initSubView
{
    self.titleScrollView = [[UIScrollView alloc] init];
    self.titleScrollView.delegate = self;
    self.titleScrollView.showsHorizontalScrollIndicator = NO;
    self.titleScrollView.showsVerticalScrollIndicator = NO;
    self.titleScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.titleScrollView];

    self.contentScrollView = [[UIScrollView alloc] init];
    self.contentScrollView.delegate = self;
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    self.contentScrollView.pagingEnabled = YES;
    [self.view addSubview:self.contentScrollView];

    //标题下方的指示条
    self.bottomLine = [[UIImageView alloc] init];
    self.bottomLine.image = [UIImage imageNamed:@"red_line_and_shadow"];
    [self.titleScrollView addSubview:self.bottomLine];
}

/**
 *  初始化创建子视图控制器
 */
-(void)initPointDetail
{
    self.title = @"调查点详情";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //创建调查点信息VC
    PointinfoViewController *pointinfoVC = [[PointinfoViewController alloc] initWithNibName:@"PointinfoViewController" bundle:nil];
    //设置delegate
    UISplitViewController *rootVC = (UISplitViewController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    pointinfoVC.delegate = ((UINavigationController *)rootVC.viewControllers[1]).viewControllers[0];
    
    pointinfoVC.title = @"调查点";
    pointinfoVC.pointinfo = self.pointinfo;
    [self addChildViewController:pointinfoVC];
    //将调查点信息VC的 rootView 添加到当前的视图控制器中（初始默认）
    pointinfoVC.view.frame = self.view.bounds;
    [self.contentScrollView addSubview:pointinfoVC.view];
    [pointinfoVC didMoveToParentViewController:self];
    
    //创建房屋震害列表VC
    DamageinfoListController *damageinfoListVC = [[DamageinfoListController alloc] initWithNibName:@"DamageinfoListController" bundle:nil];
    damageinfoListVC.title = @"房屋震害";
    damageinfoListVC.pointid = self.pointinfo.pointid;
    damageinfoListVC.pointUploadFlag = self.pointinfo.upload;
    [self addChildViewController:damageinfoListVC];
    
    //创建人物反应列表VC
    ReactioninfoListController *reactioninfoListVC = [[ReactioninfoListController alloc] initWithNibName:@"ReactioninfoListController" bundle:nil];
    reactioninfoListVC.title = @"人物反应";
    reactioninfoListVC.pointid = self.pointinfo.pointid;
    reactioninfoListVC.pointUploadFlag = self.pointinfo.upload;
    [self addChildViewController:reactioninfoListVC];
    
    //创建其它列表VC
    OtherListViewController *otherListVC = [[OtherListViewController alloc] init];
    otherListVC.title = @"其它";
    otherListVC.pointid = self.pointinfo.pointid;
    otherListVC.pointUploadFlag = self.pointinfo.upload;
    [self addChildViewController:otherListVC];
    
    //创建宏观异常列表VC
    AbnormalinfoListController *abnormalinfoListVC = [[AbnormalinfoListController alloc] initWithNibName:@"AbnormalinfoListController" bundle:nil];
    abnormalinfoListVC.title = @"宏观异常";
    abnormalinfoListVC.pointid = self.pointinfo.pointid;
    abnormalinfoListVC.pointUploadFlag = self.pointinfo.upload;
    [self addChildViewController:abnormalinfoListVC];
}

/**
 *  创建titleScrollView上的按钮
 */
-(void)createrTitleButton
{
    //循环创建按钮
    for (int i = 0; i < self.childViewControllers.count; i++) {
        
        UIViewController *vc = self.childViewControllers[i];
        
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [titleBtn setTitle:vc.title forState:UIControlStateNormal];
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:kFontSizeOfTabButton];
        [titleBtn setTitleColor:HMColor(134, 134, 134) forState:UIControlStateNormal];
        [titleBtn setTitleColor:HMColor(30, 144, 255) forState:UIControlStateSelected];
        titleBtn.tag = 1000 + i;
        [titleBtn addTarget:self action:@selector(titleBtnTaped:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleScrollView addSubview:titleBtn];
        [self.titleBtns addObject:titleBtn];
    }
    //默认设置第一个按钮为选中
    self.selectedBtn = self.titleBtns[0];
    self.selectedBtn.selected = YES;
}

/**
 *  布局标题按钮
 */
-(void)layoutTitleBtn
{
    CGFloat titleContentWidth = 0;    //所有按钮与间隔的总宽度
    
    //循环遍历计算每个按钮的宽度
    for (int i = 0; i < self.titleBtns.count; i++) {
        UIButton *titleBtn = self.titleBtns[i];
        NSDictionary *attrDict = @{
                                   NSFontAttributeName:[UIFont systemFontOfSize:kFontSizeOfTabButton]
                                   };
        CGSize boundSize = CGSizeMake(MAXFLOAT, kHeightOfTopScrollView);
        CGSize textSize = [titleBtn.currentTitle boundingRectWithSize:boundSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrDict context:nil].size;
        //设置按钮的 Frame
        titleBtn.frame = CGRectMake(kWidthOfButtonMargin + titleContentWidth, 0, textSize.width, kHeightOfTopScrollView);
        //计算每个Btn标题和间隔的长度
        titleContentWidth += kWidthOfButtonMargin+textSize.width;
    }
   self.titleScrollView.contentSize = CGSizeMake(titleContentWidth + kWidthOfButtonMargin, kHeightOfTopScrollView);
    
    //如果所有按钮与间隔的总宽度小于 scrollView 的宽度，则以scrollView宽度的平均值为按钮的宽
    if (titleContentWidth <= self.titleScrollView.bounds.size.width) {
       CGFloat titleBtnWidth = self.titleScrollView.bounds.size.width / self.childViewControllers.count;
            //设置每个按钮的 Frame
            for (int i = 0; i < self.titleBtns.count; i++){
                UIButton *titleBtn = self.titleBtns[i];
                titleBtn.frame = CGRectMake(i * titleBtnWidth, 0, titleBtnWidth, kHeightOfTopScrollView);
            }
        
        self.titleScrollView.contentSize = self.titleScrollView.bounds.size;
    }
    
    //设置指示条的位置
    self.bottomLine.frame = CGRectMake(self.selectedBtn.frame.origin.x, 0, CGRectGetWidth(self.selectedBtn.frame), kHeightOfTopScrollView);
}


#pragma mark -- 协议方法 --
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.contentScrollView) {

        int index = (int)(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5);
        
        //设置当前页面索引
        self.currentPage = index;
        if (self.currentPage == kPageTypePoint) {
            self.rightItem.title = @"编辑";
        }else{
            self.rightItem.title = @"新增";
        }
        
        [self addViewOfChildViewControllerWithContentScrollView:scrollView];

        self.selectedBtn.selected = NO;
        self.selectedBtn = self.titleBtns[index];
        self.selectedBtn.selected = YES;
        
        [self setTitleBtnPosition];
    }
}

#pragma mark -- 事件方法 --
/**
 *  导航栏右侧按钮点击调用
 */
-(void)rigthItemTap:(id)sender
{
    if (self.currentPage == kPageTypePoint) {
        
        PointinfoViewController *pointinfoVC = self.childViewControllers[0];
        
        if (pointinfoVC.actionType == kActionTypeShow) {
            self.rightItem.title = @"确定";
            pointinfoVC.actionType = kactionTypeEdit;
        }else if(pointinfoVC.actionType == kactionTypeEdit){
            self.rightItem.title = @"编辑";
            //更新数据
            [pointinfoVC updatePointinfo];
            pointinfoVC.actionType = kActionTypeShow;
        }
    }else if (self.currentPage == kPageTypeDamage) {
        
        DamageinfoListController *damageinfoListVC = self.childViewControllers[1];
        
        DamageinfoViewController *damageinfoVC = [[DamageinfoViewController alloc] init];
        damageinfoVC.actionType = kActionTypeAdd;
        damageinfoVC.pointid = self.pointinfo.pointid;
        
        damageinfoVC.delegate = damageinfoListVC;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:damageinfoVC];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
        
    }else if (self.currentPage == kPageTypeReaction){
        
        ReactioninfoListController *reactioninfoListVC = self.childViewControllers[2];
        
        ReactioninfoViewController *reactionifoVC = [[ReactioninfoViewController alloc] init];
        reactionifoVC.actionType = kActionTypeAdd;
        reactionifoVC.pointid = self.pointinfo.pointid;
        
        reactionifoVC.delegate = reactioninfoListVC;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:reactionifoVC];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
        
    }else if (self.currentPage == kPageTypeOther){
        
        OtherListViewController*otherListVC = self.childViewControllers[3];
        
        OtherViewController *otherVC = [[OtherViewController alloc] init];
        otherVC.actionType = kActionTypeAdd;
        otherVC.pointid = self.pointinfo.pointid;
        
        otherVC.delegate = otherListVC;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:otherVC];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
        
    }else if (self.currentPage ==kPageTypeAbnormal){
        
        AbnormalinfoListController*abnormalinfoListVC = self.childViewControllers[4];
        
        AbnormalinfoViewController *abnormalVC = [[AbnormalinfoViewController alloc] init];
        abnormalVC.actionType = kActionTypeAdd;
        abnormalVC.pointid = self.pointinfo.pointid;
        
        abnormalVC.delegate = abnormalinfoListVC;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:abnormalVC];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        [self presentViewController:nav animated:YES completion:nil];
    }
}

/**
 *  标题按钮被点击时调用
 */
-(void)titleBtnTaped:(UIButton *)sender
{
    self.selectedBtn.selected = NO;
    self.selectedBtn = sender;
    self.selectedBtn.selected = YES;
    
    NSInteger index = self.selectedBtn.tag - 1000;
    CGPoint contentScrollViewOffset = CGPointMake(index *self.contentScrollView.bounds.size.width, 0);
    [self.contentScrollView setContentOffset:contentScrollViewOffset animated:YES];
    
    [self setTitleBtnPosition];
    
    //设置当前页面索引
    self.currentPage = index;
}

#pragma mark -- 内部方法 --
/**
 *  将ChildViewController的 View 添加到当前视图控制器中
 */
-(void)addViewOfChildViewControllerWithContentScrollView:(UIScrollView *)scrollView
{
    int index = (int)(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5);
    
    UIViewController *vc = self.childViewControllers[index];
    if (!vc.view.superview) {
        //添加到当前视图控制器中
        vc.view.frame = CGRectMake(index * scrollView.bounds.size.width, 0, scrollView.bounds.size.width, scrollView.bounds.size.height);
        [self.contentScrollView addSubview:vc.view];
    }
}

/**
 *  将选中的标题按钮移动到视图中间,如果titleScrollView已经滚动到了最左边或最右边则不移动标题按钮
 */
-(void)setTitleBtnPosition
{
    //按钮位于中点时 contentOffset 的X轴方向的值
    CGFloat offsetX = self.selectedBtn.center.x - self.titleScrollView.bounds.size.width/2;
    // x 轴最大可以滚动的值
    CGFloat offsetXOfMax = self.titleScrollView.contentSize.width - self.titleScrollView.bounds.size.width;
    
    if (offsetX > offsetXOfMax) {
        offsetX = offsetXOfMax;
    }else if (offsetX < 0){
        offsetX = 0;
    }
    
    CGPoint offset =CGPointMake(offsetX, 0);
    
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomLine.frame = CGRectMake(self.selectedBtn.frame.origin.x, 0, CGRectGetWidth(self.selectedBtn.frame), kHeightOfTopScrollView);
        self.titleScrollView.contentOffset = offset;
        
    } completion:^(BOOL finished) {
        
    }];
}

@end
