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

@interface LocationHelper ()<AMapSearchDelegate>

@property (strong, nonatomic) AMapSearchAPI *searchApi;
@property (assign, nonatomic) BOOL isUploadUserinfo;

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

/**
 *  逆地理编码请求
 */
-(void)reverseGeocode
{
    self.isUploadUserinfo = NO;
    
    AppDelegate *appdl = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CLLocationCoordinate2D coordinate = appdl.currentCoordinate;
    
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;

    [self.searchApi AMapReGoecodeSearch:regeo];
}

/**
 *  上传用户信息
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
    NSDictionary *trackDict = @{
                                @"time":datestr,
                                @"lon":lon,
                                @"lat":lat
                                };
    [[TrackTableHelper sharedInstance] insertDataWith:trackDict];
    
    //发起逆地理编码请求
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension = YES;
    [self.searchApi AMapReGoecodeSearch:regeo];
}


#pragma mark - AMapSearchDelegate
/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil){
        
        if (self.isUploadUserinfo) {
            
            NSMutableDictionary *parameters =[[NSMutableDictionary alloc] init];
            
            UserModel *userinfo = [ArchiverCacheHelper getLocaldataBykey:User_Archiver_Key filePath:User_Archiver_Path];
            NSString *lon = [NSString stringWithFormat:@"%f",request.location.longitude];
            NSString *lat = [NSString stringWithFormat:@"%f",request.location.latitude];
            
            parameters[@"userlon"] = lon;
            parameters[@"userlat"] = lat;
            parameters[@"userid"] = userinfo.userid;
            parameters[@"useraddress"] = response.regeocode.formattedAddress;
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager POST:URL_uploadlocation parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"userinfo数据上传成功: %@", responseObject);
                userinfo.useraddress = response.regeocode.formattedAddress;
                userinfo.userlat = lat;
                userinfo.userlon = lon;
                [ArchiverCacheHelper saveObjectToLoacl:userinfo key:User_Archiver_Key filePath:User_Archiver_Path];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"userinfo数据上传失败");
            }];
        }else{
            if ([self.delegate respondsToSelector:@selector(reverseGeocodeSuccess:)]) {
                [self.delegate reverseGeocodeSuccess:response.regeocode.formattedAddress];
            }
        }
    }else{
        if (self.isUploadUserinfo) {
            NSLog(@"逆地理编码");
        }else{
            if ([self.delegate respondsToSelector:@selector(reverseGeocodeFailure)]) {
                [self.delegate reverseGeocodeFailure];
            }
        }
    }
}

@end
