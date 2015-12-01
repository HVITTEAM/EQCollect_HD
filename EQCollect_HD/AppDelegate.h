//
//  AppDelegate.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/8/27.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
@class EarthInfo;

@interface AppDelegate : UIResponder <UIApplicationDelegate,AMapLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong ,nonatomic) EarthInfo *earthinfo;
@property (strong, nonatomic) CLLocation *currentLocation;          //当前位置信息
@property (strong, atomic) NSMutableString *currrentaddr;        //当前地址
-(void)addTimer;
-(void)removeTimer;
@end

