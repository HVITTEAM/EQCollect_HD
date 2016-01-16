//
//  LocationHelper.m
//  EQCollect_HD
//
//  Created by shi on 15/10/16.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "LocationHelper.h"
#import "AppDelegate.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import "TrackTableHelper.h"
#import "CurrentUser.h"
#import "TrackModel.h"

@interface LocationHelper ()<AMapSearchDelegate>

@property (strong, nonatomic) AMapSearchAPI *searchApi;                 //高德搜索 API

@property (assign, nonatomic) BOOL isUploadUserinfo;                    //指示是上传用户信息还是单单解析地址

@end

@implementation LocationHelper

-(instancetype)init
{
    if (self = [super init]) {
        self.searchApi = [[AMapSearchAPI alloc] init];
        self.searchApi.delegate = self;
    }
    return self;
}

#pragma mark -- 公开方法 --
/**
 *  单纯的逆地理编码请求
 */
-(void)reverseGeocode
{
    self.isUploadUserinfo = NO;
    
    AppDelegate *appdl = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CLLocationCoordinate2D coordinate = appdl.currentCoordinate;
    
    //创建逆地理编码请求
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;

    [self.searchApi AMapReGoecodeSearch:regeo];
}

/**
 *  逆地理编码请求后上传用户信息
 */
-(void)uploadUserinfo
{
    self.isUploadUserinfo = YES;
    
    AppDelegate *appdl = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CLLocationCoordinate2D coordinate = appdl.currentCoordinate;
    NSString *lon = [NSString stringWithFormat:@"%f",coordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f",coordinate.latitude];
    
    //将数据保存到本地数据库中用作轨迹
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *date = [NSDate date];
    NSString *datestr = [formatter stringFromDate:date];
//    NSDictionary *trackDict = @{
//                                @"time":datestr,
//                                @"lon":lon,
//                                @"lat":lat
//                                };
    TrackModel *trackModel = [[TrackModel alloc] init];
    trackModel.time = datestr;
    trackModel.lon = lon;
    trackModel.lat = lat;
    
    [[TrackTableHelper sharedInstance]insertDataWithTrackinfoModel:trackModel];
    
    //发起逆地理编码请求
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    [self.searchApi AMapReGoecodeSearch:regeo];
}

#pragma mark -- 协议方法 --
#pragma mark  AMapSearchDelegate
/* 逆地理编码回调 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil){         //逆地理编码成功
        
        if (self.isUploadUserinfo) {
            
            NSMutableDictionary *parameters =[[NSMutableDictionary alloc] init];
            
            NSString *lon = [NSString stringWithFormat:@"%f",request.location.longitude];
            NSString *lat = [NSString stringWithFormat:@"%f",request.location.latitude];
            
            parameters[@"userlon"] = lon;
            parameters[@"userlat"] = lat;
            parameters[@"userid"] = [CurrentUser shareInstance].userid;
            parameters[@"useraddress"] = response.regeocode.formattedAddress;
            NSLog(@"上传位置%@",parameters);
            
            [CommonRemoteHelper RemoteWithUrl:URL_uploadlocation parameters:parameters type:CommonRemoteTypePost success:^(id responseObject) {
                NSLog(@"userinfo数据上传成功: %@", responseObject);
                [CurrentUser shareInstance].userlat = lat;
                [CurrentUser shareInstance].userlon = lon;
                [CurrentUser shareInstance].useraddress = response.regeocode.formattedAddress;
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"userinfo数据上传失败");
            }];
  
        }else{
            if ([self.delegate respondsToSelector:@selector(reverseGeocodeSuccess:)]) {
                [self.delegate reverseGeocodeSuccess:response.regeocode.formattedAddress];
            }
        }
    }else{                    //逆地理编码失败
        if (self.isUploadUserinfo) {
            NSLog(@"逆地理编码失败");
        }else{
            if ([self.delegate respondsToSelector:@selector(reverseGeocodeFailure)]) {
                [self.delegate reverseGeocodeFailure];
            }
        }
    }
}

@end
