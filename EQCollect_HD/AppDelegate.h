//
//  AppDelegate.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/8/27.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapNaviKit/AMapNaviKit.h>

@class EarthInfo;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong ,nonatomic) EarthInfo *earthinfo;                //地震信息
@property (assign, nonatomic) CLLocationCoordinate2D currentCoordinate;          //当前位置信息

-(void)removeTimer;

@end

