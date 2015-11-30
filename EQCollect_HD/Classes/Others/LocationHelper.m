//
//  LocationHelper.m
//  EQCollect_HD
//
//  Created by shi on 15/10/16.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "LocationHelper.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapNaviKit/MAGeometry.h>
#import "TrackTableHelper.h"

@implementation LocationHelper

-(instancetype)init
{
    if (self = [super init]) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return self;
}

-(void)reverseGeocodeWithSuccess:(void (^)(NSString *))success failure:(void (^)(void))failure
{
    AppDelegate *appdl = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.geocoder reverseGeocodeLocation:appdl.currentLocation completionHandler:
     ^(NSArray *placemarks, NSError *error){
         // 如果解析结果的集合元素的个数大于1，表明解析得到了经度、纬度信息
         if (placemarks.count > 0){
             // 处理第一个解析结果
             CLPlacemark* placemark = placemarks[0];
             // 获取详细地址信息
             NSArray* addrArray = [placemark.addressDictionary
                                   objectForKey:@"FormattedAddressLines"];
             // 将详细地址拼接成一个字符串
             NSMutableString *addr = [[NSMutableString alloc] init];
             for(int i = 0 ; i < addrArray.count ; i ++){
                 [addr appendString:addrArray[i]];
             }
             appdl.currrentaddr = addr;
             success(addr);
             NSLog(@"reverseGeocode成功%@",addr);
         }
         else{
             //失败
             NSLog(@"reverseGeocode失败");
             //failure();
         }
     }];
}

-(void)uploadUserinfo
{
    
    AppDelegate *appdl = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *lon = [NSString stringWithFormat:@"%f",appdl.currentLocation.coordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f",appdl.currentLocation.coordinate.latitude];
 
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
    
    
    UserModel *userinfo = [ArchiverCacheHelper getLocaldataBykey:User_Archiver_Key filePath:User_Archiver_Path];
    NSMutableDictionary *parameters1 =[[NSMutableDictionary alloc] initWithObjectsAndKeys:userinfo.userid,@"userid",nil];
    parameters1[@"userlon"] = lon;
    parameters1[@"userlat"] = lat;
    //    NSDictionary *parameters = [userinfo keyValues];
    //    NSMutableDictionary *parameters1 = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    [self.geocoder reverseGeocodeLocation:appdl.currentLocation completionHandler:
     ^(NSArray *placemarks, NSError *error){
         // 如果解析结果的集合元素的个数大于1，表明解析得到了经度、纬度信息
         if (placemarks.count > 0){
             // 处理第一个解析结果
             CLPlacemark* placemark = placemarks[0];
             // 获取详细地址信息
             NSArray* addrArray = [placemark.addressDictionary
                                   objectForKey:@"FormattedAddressLines"];
             // 将详细地址拼接成一个字符串
             NSMutableString *addr = [[NSMutableString alloc] init];
             for(int i = 0 ; i < addrArray.count ; i ++){
                 [addr appendString:addrArray[i]];
             }
             NSLog(@"反地址解释成功");
             appdl.currrentaddr = addr;
             parameters1[@"useraddress"] = addr;
             NSLog(@"自动上传的参数parameters1%@",parameters1);
             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
             [manager POST:URL_uploadlocation parameters:parameters1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"userinfo数据上传成功: %@", responseObject);
                 userinfo.useraddress = addr;
                 userinfo.userlat = lat;
                 userinfo.userlon = lon;
                 [ArchiverCacheHelper saveObjectToLoacl:userinfo key:User_Archiver_Key filePath:User_Archiver_Path];
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"userinfo数据上传失败");
             }];
             
         }else{
             //失败
             NSLog(@"反地址解释失败");
             parameters1[@"useraddress"] = @"当前地址未知";
             NSLog(@"自动上传的参数parameters1%@",parameters1);
             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
             [manager POST:URL_uploadlocation parameters:parameters1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"userinfo数据上传成功: %@", responseObject);
                 userinfo.useraddress = @"当前地址未知";
                 userinfo.userlat = lat;
                 userinfo.userlon = lon;
                 [ArchiverCacheHelper saveObjectToLoacl:userinfo key:User_Archiver_Key filePath:User_Archiver_Path];
                 
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"userinfo数据上传失败");
             }];

         }
     }];
}



@end
