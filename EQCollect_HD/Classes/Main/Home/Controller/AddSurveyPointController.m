//
//  AddSurveyPointController.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/6.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "AddSurveyPointController.h"

@interface AddSurveyPointController ()

@end

@implementation AddSurveyPointController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigation];
}

/**
 *  初始化导航栏
 */
-(void)initNavigation
{
    self.title = @"新增调查点";
    self.view.backgroundColor = HMGlobalBg;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
}

-(void)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
