//
//  HMControllerTool.h
//  黑马微博
//
//  Created by apple on 14-7-8.
//  Copyright (c) 2014年 heima. All rights reserved.
//  负责控制器相关的操作

#import <Foundation/Foundation.h>
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "LoginViewController.h"

@interface HMControllerTool : NSObject
/**
 *  选择根控制器
 */
+ (void)chooseRootViewController;

/**
 *  设置主页控制器
 */
+ (void)setRootViewController;

/**
 *  设置登陆控制器
 */
+ (void)setLoginViewController;
@end
