//
//  CacheUtil.h
//  EQCollect_HD
//
//  Created by shi on 15/12/28.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PointModel,AbnormalinfoModel,ReactionModel,DamageModel,OtherModel;

@interface CacheUtil : NSObject

@property(strong,nonatomic)PointModel *cachePoint;             //缓存的上一次调查点数据

@property(strong,nonatomic)AbnormalinfoModel *cacheAbnormalinfo;      //缓存的上一次宏观异常数据

@property(strong,nonatomic)ReactionModel *cacheReaction;          //缓存的上一次人物反应数据

@property(strong,nonatomic)DamageModel *cacheDamage;            //缓存的上一次房屋震害数据

@property(strong,nonatomic)OtherModel *cacheOther;             //缓存的上一次其它表数据

+(instancetype)shareInstance;

/**
 *  设置缓存调查点数据
 */
-(void)setCachePointWithDict:(NSDictionary *)aDict;

/**
 *  设置缓存宏观异常数据
 */
-(void)setCacheAbnormalinfoWithDict:(NSDictionary *)aDict;

/**
 *  设置缓存人物反应数据
 */
-(void)setCacheReactionWithDict:(NSDictionary *)aDict;

/**
 *  设置缓存房屋震害数据
 */
-(void)setCacheDamageWithDict:(NSDictionary *)aDict;

/**
 *  设置缓存其它表数据
 */
-(void)setCacheOtherWithDict:(NSDictionary *)aDict;

@end
