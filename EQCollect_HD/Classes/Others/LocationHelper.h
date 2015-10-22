//
//  LocationHelper.h
//  EQCollect_HD
//
//  Created by shi on 15/10/16.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationHelper : NSObject<CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLLocation *currentLocation;          //当前位置信息
@property (strong, nonatomic) NSMutableString *currrentaddr;        //当前地址
@property (strong, nonatomic) NSTimer *timer;

+(instancetype)sharedLocationHelper;
-(void)setupLocationManager;
-(void)reverseGeocodeWithSuccess:(void (^)(NSString *address))success failure:(void (^)(void))failure;

-(void)uploadUserinfo;
-(void)addTimer;
-(void)removeTimer;

@end

