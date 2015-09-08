//
//  PersonCenterController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/2.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "PersonCenterController.h"

@interface PersonCenterController ()

@end

@implementation PersonCenterController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavigation]; 
}

/**

 *  初始化导航栏 */
-(void)initNavigation
{
    self.title = @"个人中心";
    self.view.backgroundColor = HMGlobalBg;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    
    PointinfoTableHelper *helper = [[PointinfoTableHelper alloc] init];
    [helper initDataBase];
    [helper createTable];
    [helper insertData];
    [helper selectData];
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
