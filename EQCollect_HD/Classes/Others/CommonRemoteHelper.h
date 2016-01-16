//
//  CommonRemoteHelper.h
//  GPSNavDemo
//
//  Created by 董徐维 on 15/3/16.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef NS_ENUM(NSInteger, CommonRemoteType) {
    CommonRemoteTypePost,
    CommonRemoteTypeGet,
};


@interface CommonRemoteHelper : NSObject

+ (void)setCompletionBlockWithUrl:(NSString *)url
                          success:(void (^)(NSDictionary *dict, id responseObject))success
                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


/**
 *  发送数据，不包括图片等多媒体数据
 */
+(AFHTTPRequestOperation *)RemoteWithUrl:(NSString *)url
          parameters:(id)parameters
                type:(CommonRemoteType)type
             success:(void (^)(id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


/**
 *  发送数据，包括图片等多媒体数据
 */
+(AFHTTPRequestOperation *)remoteImageWithUrl:(NSString *)url
               parameters:(id)parameters
              formObjects:(NSMutableArray *)formObjects
                  success:(void(^)(id responseObject))success
                  failure:(void(^)(AFHTTPRequestOperation *operation,NSError *error))failure;

@end
