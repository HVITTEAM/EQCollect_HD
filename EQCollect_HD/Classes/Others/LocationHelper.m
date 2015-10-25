//
//  LocationHelper.m
//  EQCollect_HD
//
//  Created by shi on 15/10/16.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "LocationHelper.h"

@implementation LocationHelper

+(instancetype)sharedLocationHelper
{
    static LocationHelper *locationHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationHelper = [[LocationHelper alloc] init];
        locationHelper.locationManager = [[CLLocationManager alloc] init];
        locationHelper.geocoder = [[CLGeocoder alloc] init];
        //locationHelper.currrentaddr = [NSMutableString stringWithString:@"万塘路252号2006室"];
        //locationHelper.currentLocation = [[CLLocation alloc] initWithLatitude:37.333607 longitude:-122.050640];
        
    });
    return locationHelper;
}

-(void)setupLocationManager{
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"开始定位");
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 200.0;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        //ios8以上要授权
        if (IOS_VERSION >=8.0) {
            [self.locationManager requestWhenInUseAuthorization];//使用中授权
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }else{
        //失败
        [[[UIAlertView alloc] initWithTitle:@"提醒" message:@"定位失败，请确定是否开启定位功能" delegate:nil
                          cancelButtonTitle:@"确定" otherButtonTitles: nil]show];
    }
}

-(void)reverseGeocodeWithSuccess:(void (^)(NSString *))success failure:(void (^)(void))failure
{
    [self.geocoder reverseGeocodeLocation:self.currentLocation completionHandler:
     ^(NSArray *placemarks, NSError *error){
         // 如果解析结果的集合元素的个数大于1，表明解析得到了经度、纬度信息
         if (placemarks.count > 0){
             // 处理第一个解析结果
             CLPlacemark* placemark = placemarks[0];
             // 获取详细地址信息
             NSArray* addrArray = [placemark.addressDictionary
                                   objectForKey:@"FormattedAddressLines"];
             // 将详细地址拼接成一个字符串
             self.currrentaddr = [[NSMutableString alloc] init];
             for(int i = 0 ; i < addrArray.count ; i ++){
                 [self.currrentaddr appendString:addrArray[i]];
             }
             success(self.currrentaddr);
             NSLog(@"reverseGeocode成功%@",self.currrentaddr);
         }
         else{
             //失败
             NSLog(@"reverseGeocode失败%@",self.currrentaddr);
//             failure();
             //[self reverseGeocodeWithSuccess:success failure:nil];
         }
     }];
    
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    NSLog(@"定位成功");
    self.currentLocation = [locations lastObject];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"定位失败");
}

-(void)addTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(uploadUserinfo) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)removeTimer{
    [self.timer invalidate];
}

-(void)uploadUserinfo
{
    NSString *lon = [NSString stringWithFormat:@"%f",self.currentLocation.coordinate.longitude];
    NSString *lat = [NSString stringWithFormat:@"%f",self.currentLocation.coordinate.latitude];
    
    UserModel *userinfo = [ArchiverCacheHelper getLocaldataBykey:User_Archiver_Key filePath:User_Archiver_Path];
    NSMutableDictionary *parameters1 =[[NSMutableDictionary alloc] initWithObjectsAndKeys:userinfo.userid,@"userid",nil];
    parameters1[@"userlon"] = lon;
    parameters1[@"userlat"] = lat;
    //    NSDictionary *parameters = [userinfo keyValues];
    //    NSMutableDictionary *parameters1 = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    [self.geocoder reverseGeocodeLocation:self.currentLocation completionHandler:
     ^(NSArray *placemarks, NSError *error){
         // 如果解析结果的集合元素的个数大于1，表明解析得到了经度、纬度信息
         if (placemarks.count > 0){
             // 处理第一个解析结果
             CLPlacemark* placemark = placemarks[0];
             // 获取详细地址信息
             NSArray* addrArray = [placemark.addressDictionary
                                   objectForKey:@"FormattedAddressLines"];
             // 将详细地址拼接成一个字符串
             self.currrentaddr = [[NSMutableString alloc] init];
             for(int i = 0 ; i < addrArray.count ; i ++){
                 [self.currrentaddr appendString:addrArray[i]];
             }
             NSLog(@"反地址解释成功");
             parameters1[@"useraddress"] = self.currrentaddr;
             NSLog(@"自动上传的参数parameters1%@",parameters1);
             AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
             [manager POST:URL_uploadlocation parameters:parameters1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"userinfo数据上传成功: %@", responseObject);
                 userinfo.useraddress = self.currrentaddr;
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
                 userinfo.useraddress = self.currrentaddr;
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
