//
//  DamageModel.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
//房屋震害信息表(damageinfo)
//#define DAMAGEID         @"damageid"                              //房屋震害编号
//#define DAMAGETIME       @"damagetime"                            //调查时间
//#define BUILDINGAGE      @"buildingage"                           //建造年代
//#define DAMAGEAREA       @"damagearea"                            //房屋面积
//#define FIELDTYPE        @"fieldtype"                             //场地类型
//#define DAMAGELEVEL      @"damagelevel"                           //破坏等级
//#define ZRCORXQ          @"zrcorxq"                               //自然村或小区
//#define DWORZH           @"dworzh"                                //单位或住户
//#define FORTIFICATIONINTENSITY    @"fortificationintensity"       //设防烈度
//#define DAMAGESITUATION  @"damagesituation"                       //破坏情况
//#define DAMAGEINDEX      @"damageindex"                           //震害指数(自动)
//#define DAMAGERINDEX     @"damagerindex"                          //震害指数(人工)
//#define HOUSETYPE        @"housetype"                             //房屋类型
//
//#define POINTID          @"pointid"                                //调查点编号
//#define UPLOAD           @"upload"                                 //上传状态

#import <Foundation/Foundation.h>

@interface DamageModel : NSObject

@property (nonatomic, copy) NSString *damageid;
@property (nonatomic, copy) NSString *damagetime;
@property (nonatomic, copy) NSString *buildingage;
@property (nonatomic, copy) NSString *damagearea;
@property (nonatomic, copy) NSString *fieldtype;
@property (nonatomic, copy) NSString *damagelevel;
@property (nonatomic, copy) NSString *zrcorxq;
@property (nonatomic, copy) NSString *dworzh;
@property (nonatomic, copy) NSString *fortificationintensity;
@property (nonatomic, copy) NSString *damagesituation;
@property (nonatomic, copy) NSString *damageindex;
@property (nonatomic, copy) NSString *damagerindex;
@property (nonatomic, copy) NSString *housetype;
@property (nonatomic, copy) NSString *pointid;
@property (nonatomic, copy) NSString *upload;

@end
