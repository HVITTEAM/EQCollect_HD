//
//  LocationHelper.h
//  EQCollect_HD
//
//  Created by shi on 15/10/16.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@interface LocationHelper : NSObject<CLLocationManagerDelegate>

@property (strong, nonatomic) CLGeocoder *geocoder;

-(void)reverseGeocodeWithSuccess:(void (^)(NSString *address))success failure:(void (^)(void))failure;

-(void)uploadUserinfo;


@end

