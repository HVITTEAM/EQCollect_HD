//
//  HMControllerTool.m
//  黑马微博
//
//  Created by apple on 14-7-8.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HMControllerTool.h"

@implementation HMControllerTool
+ (void)chooseRootViewController
{
    
}

+ (void)setRootViewController
{
    MasterViewController *masterView = [[MasterViewController alloc] init];
    UINavigationController *masterNav =  [[UINavigationController alloc] initWithRootViewController:masterView];
    
    DetailViewController *detailView = [[DetailViewController alloc] init];
    UINavigationController *detailNav =  [[UINavigationController alloc] initWithRootViewController:detailView];
    
    // 设置UISplitViewController的代理
    UISplitViewController *split = [[UISplitViewController alloc] init];
    split.viewControllers = @[masterNav,detailNav];
    split.delegate = detailNav.viewControllers[0];
    // 切换控制器
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //将其设置为当前窗口的跟视图控制器
    window.rootViewController = split;
}

+ (void)setLoginViewController
{
    LoginViewController *loginView = [[LoginViewController alloc] init];
    // 切换控制器
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //将其设置为当前窗口的跟视图控制器
    window.rootViewController = loginView;
}
@end
