//
//  CacheUtil.m
//  EQCollect_HD
//
//  Created by shi on 15/12/28.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "CacheUtil.h"
#import "PointModel.h"
#import "AbnormalinfoModel.h"
#import "ReactionModel.h"
#import "DamageModel.h"
#import "OtherModel.h"

@implementation CacheUtil

+(instancetype)shareInstance
{
    static CacheUtil *cacheUtil = nil;
    static dispatch_once_t onceToke;
    
    dispatch_once(&onceToke, ^{
        cacheUtil = [[CacheUtil alloc] init];
    });
    return cacheUtil;
}



@end
