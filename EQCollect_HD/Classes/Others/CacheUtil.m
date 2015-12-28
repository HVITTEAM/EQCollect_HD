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
//        cacheUtil.cachePoint = [[PointModel alloc] init];
//        cacheUtil.cacheAbnormalinfo = [[AbnormalinfoModel alloc]init];
//        cacheUtil.cacheReaction = [[ReactionModel alloc] init];
//        cacheUtil.cacheDamage = [[DamageModel alloc] init];
//        cacheUtil.cacheOther = [[OtherModel alloc] init];
    });
    return cacheUtil;
}

-(void)setCachePointWithDict:(NSDictionary *)aDict
{
    PointModel *point = [PointModel objectWithKeyValues:aDict];
    self.cachePoint = point;
}

-(void)setCacheAbnormalinfoWithDict:(NSDictionary *)aDict
{
    AbnormalinfoModel *abnormal = [AbnormalinfoModel objectWithKeyValues:aDict];
    self.cacheAbnormalinfo = abnormal;
}

-(void)setCacheReactionWithDict:(NSDictionary *)aDict
{
    ReactionModel *reaction = [ReactionModel objectWithKeyValues:aDict];
    self.cacheReaction = reaction;
}

-(void)setCacheDamageWithDict:(NSDictionary *)aDict
{
    DamageModel *damage = [DamageModel objectWithKeyValues:aDict];
    self.cacheDamage = damage;
}

-(void)setCacheOtherWithDict:(NSDictionary *)aDict
{
    OtherModel *other = [OtherModel objectWithKeyValues:aDict];
    self.cacheOther = other;
}

@end
