//
//  LocationHelper.h
//  EQCollect_HD
//
//  Created by shi on 15/10/16.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol locationHelperDelegate;

@interface LocationHelper : NSObject

@property (weak,nonatomic)id<locationHelperDelegate>delegate;

-(void)uploadUserinfo;

-(void)reverseGeocode;

@end

@protocol locationHelperDelegate <NSObject>

-(void)reverseGeocodeSuccess:(NSString *)address;
-(void)reverseGeocodeFailure;

@end