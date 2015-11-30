//
//  BaseNaviViewController.h
//  officialDemoNavi
//
//  Created by 刘博 on 14-7-24.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AMapNaviKit/MAMapKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

#import "iflyMSC/IFlySpeechError.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"

@interface BaseNaviViewController : UIViewController <MAMapViewDelegate,AMapNaviManagerDelegate,IFlySpeechSynthesizerDelegate,UISearchBarDelegate,AMapSearchDelegate>

@property (nonatomic, weak) MAMapView *mapView;

@property (nonatomic, strong) AMapNaviManager *naviManager;

@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;

@property (nonatomic, strong) AMapSearchAPI *searchApi;


-(void)showNaviParamsViewController;
- (void)returnAction;

@end
