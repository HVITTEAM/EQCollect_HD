//
//  AppDelegate.m
//  EQCollect_HD
//
//  Created by 董徐维 on 15/8/27.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationHelper.h"
#import "ArchiverCacheHelper.h"
#import "EarthInfo.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechConstant.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySetting.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface AppDelegate ()
{
    CLLocationManager *_locationManager;
    NSTimer *_timer;
    LocationHelper *_locationHelp;
    BOOL _isFirst;
}
-(void)setupLocationManager;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 1.创建窗口
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    
    // 2.显示窗口(成为主窗口)
    [self.window makeKeyAndVisible];
    
    _isFirst = YES;
    //开启定位
    [self setupLocationManager];
    //获取 earthid
    [self getEarthid];
    
    [MAMapServices sharedServices].apiKey = @"4e4a9f0b5e8b6511cfdb23e7fc29b421";
    [AMapNaviServices sharedServices].apiKey = @"4e4a9f0b5e8b6511cfdb23e7fc29b421";
    [AMapSearchServices sharedServices].apiKey = @"4e4a9f0b5e8b6511cfdb23e7fc29b421";
    //导航语音
    [self configIFlySpeech];

    
    if ([ArchiverCacheHelper getLocaldataBykey:User_Archiver_Key filePath:User_Archiver_Path])
    {
        NSLog(@"已经存在用户");
        [HMControllerTool setRootViewController];
    }
    else
    {
        NSLog(@"新登录用户");
        [HMControllerTool setLoginViewController];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   [self removeTimer];
}

- (void)configIFlySpeech
{
    [IFlySpeechUtility createUtility:[NSString stringWithFormat:@"appid=%@,timeout=%@",@"5565399b",@"20000"]];
    
    [IFlySetting setLogFile:LVL_NONE];
    [IFlySetting showLogcat:NO];
    
    // 设置语音合成的参数
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];//合成的语速,取值范围 0~100
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"50" forKey:[IFlySpeechConstant VOLUME]];//合成的音量;取值范围 0~100
    
    // 发音人,默认为”xiaoyan”;可以设置的参数列表可参考个 性化发音人列表;
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"xiaoyan" forKey:[IFlySpeechConstant VOICE_NAME]];
    
    // 音频采样率,目前支持的采样率有 16000 和 8000;
    [[IFlySpeechSynthesizer sharedInstance] setParameter:@"8000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    // 当你再不需要保存音频时，请在必要的地方加上这行。
    [[IFlySpeechSynthesizer sharedInstance] setParameter:nil forKey:[IFlySpeechConstant TTS_AUDIO_PATH]];
}


-(void)setupLocationManager{
    _locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"开始定位");
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 200.0;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //ios8以上要授权
        if (IOS_VERSION >=8.0) {
            //[_locationManager requestWhenInUseAuthorization];//使用中授权
            [_locationManager requestAlwaysAuthorization];
        }
        [_locationManager startUpdatingLocation];
    }else{
        //失败
        [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"定位失败，请确定是否开启定位功能" delegate:nil
                          cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
    }
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"定位成功");
    self.currentLocation = [locations lastObject];
    if (_isFirst) {
        _isFirst = NO;
        //开启定时发送位置信息功能
        AppDelegate *appdl = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        [appdl addTimer];
        [_timer fire];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"定位失败");
}

-(void)addTimer{
    _locationHelp = [[LocationHelper alloc] init];
    _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:_locationHelp selector:@selector(uploadUserinfo) userInfo:nil repeats:YES];
    [_timer fire];
    //[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)removeTimer{
    [_timer invalidate];
}

-(void)getEarthid
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:URL_isstart parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"获取 earthid 成功");
        
        NSLog(@"%@",responseObject);
        
        self.earthinfo = [EarthInfo objectWithKeyValues:[responseObject firstObject]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"获取 earthid 失败");
    }];
}

@end
