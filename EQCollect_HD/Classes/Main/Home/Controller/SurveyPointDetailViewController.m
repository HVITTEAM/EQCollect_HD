//
//  SurveyPointDetailViewController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/1.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
#import "SurveyPointDetailViewController.h"

@interface SurveyPointDetailViewController ()

@end

@implementation SurveyPointDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"调查点详情";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //创建一组UIViewController作为slideSwitchView的数据源
    self.vcArray = [[NSMutableArray alloc] init];
    for (int i = 0; i<4; i++) {
        UIViewController *vc = [[UIViewController alloc] init];
        
        vc.view = [[UIView alloc] initWithFrame:self.view.bounds];
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0,400, 80, 80)];
        lb.text = [[NSString alloc] initWithFormat:@"标题为%d",i];
        lb.font = [UIFont systemFontOfSize:18];
        lb.backgroundColor = [UIColor magentaColor];
        [vc.view addSubview:lb];
        
        vc.title = [[NSString alloc] initWithFormat:@"标题为%d",i];
        vc.view.backgroundColor = [UIColor whiteColor];
        [self.vcArray addObject:vc];
    }
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //初始化slideSwitchView
    [self initView];
}

/**
 *  初始化slideSwitchView
 */
-(void)initView
{
    if (self.slideSwitchView)
    {
        self.slideSwitchView.frame = CGRectMake(0,64,self.view.width,self.view.height-64);
    }
    else
    {
        self.slideSwitchView = [[QCSlideSwitchView alloc]initWithFrame:CGRectMake(0,64,self.view.width,self.view.height-64)];
        self.slideSwitchView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.slideSwitchView.slideSwitchViewDelegate = self;
        [self.view addSubview:self.slideSwitchView];
        self.slideSwitchView.tabItemNormalColor = [QCSlideSwitchView colorFromHexRGB:@"868686"];
        self.slideSwitchView.tabItemSelectedColor = [QCSlideSwitchView colorFromHexRGB:@"1e90ff"];
        self.slideSwitchView.shadowImage = [[UIImage imageNamed:@"red_line_and_shadow"]
                                            stretchableImageWithLeftCapWidth:59.0f topCapHeight:0.0f];
        [self.slideSwitchView buildUI];
    }
}

#pragma mark SlideSwitchView协议方法
-(NSUInteger)numberOfTab:(QCSlideSwitchView *)view
{
    return 4;
}

- (UIViewController *)slideSwitchView:(QCSlideSwitchView *)view viewOfTab:(NSUInteger)number
{
    return self.vcArray[number];
}

- (void)slideSwitchView:(QCSlideSwitchView *)view didselectTab:(NSUInteger)number
{
    NSLog(@"选中了%lu",(unsigned long)number);
}

@end
