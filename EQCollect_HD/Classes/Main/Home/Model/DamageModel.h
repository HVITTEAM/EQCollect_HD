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
@property (nonatomic, assign) float damageid;
@property (nonatomic, retain) NSString *damagetime;
@property (nonatomic, retain) NSString *damageaddress;
@property (nonatomic, retain) NSString *damageintensity;
@property (nonatomic, retain) NSString *zrcorxq;
@property (nonatomic, retain) NSString *dworzh;
@property (nonatomic, retain) NSString *fortificationintensity;
@property (nonatomic, retain) NSString *damagesituation;
@property (nonatomic, retain) NSString *damageindex;
@end
