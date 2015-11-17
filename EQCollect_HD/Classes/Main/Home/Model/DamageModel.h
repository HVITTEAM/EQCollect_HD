//
//  DamageModel.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
//房屋震害信息表(damageinfo)
//字段	                 描述	    类型
//damageid	             房屋震害编号	 Int
//damagetime	         调查时间 	 Date
//damageaddress	         地址	     Varchar
//damageintensity        烈度	     Varchar
//zrcorxq	             自然村或小区	 Varchar
//dworzh	             单位或住户	 Varchar
//fortificationintensity 设防烈度	     Varchar
//damagesituation	     破坏情况 	 Varchar
//damageindex	         震害指数	     Float

#import <Foundation/Foundation.h>

@interface DamageModel : NSObject
@property (nonatomic, copy) NSString *damageid;
@property (nonatomic, copy) NSString *damagetime;
@property (nonatomic, copy) NSString *damageaddress;
@property (nonatomic, copy) NSString *damageintensity;
@property (nonatomic, copy) NSString *zrcorxq;
@property (nonatomic, copy) NSString *dworzh;
@property (nonatomic, copy) NSString *fortificationintensity;
@property (nonatomic, copy) NSString *damagesituation;
@property (nonatomic, copy) NSString *damageindex;
@property (nonatomic, copy) NSString *housetype;
@property (nonatomic, copy) NSString *pointid;
@property (nonatomic, copy) NSString *upload;
@end
