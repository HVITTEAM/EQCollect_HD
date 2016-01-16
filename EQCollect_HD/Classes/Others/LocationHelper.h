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

/**
 *  逆地理编码请求后上传用户信息
 */
-(void)uploadUserinfo;

/**
 *  单纯的逆地理编码请求
 */
-(void)reverseGeocode;

@end

/////////////////////////////////////////////////////////////////////////////
/**
 *  逆地理编码协议
 */
@protocol locationHelperDelegate <NSObject>

/**
 *  逆地理编码成功后回调
 */
-(void)reverseGeocodeSuccess:(NSString *)address;

/**
 *  逆地理编码失败后回调
 */
-(void)reverseGeocodeFailure;

@end

