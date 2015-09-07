//
//  AbnormalinfoModel.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
//宏观异常信息表(abnormalinfo)
//字段	              描述	         类型
//abnormalid	     宏观异常编号    	  Int
//abnormaltime	     调查时间     	  Date
//informant	         被调查者	          Varchar
//abnormalintensity	 烈度	          Varchar
//groundwater	     地下水         	  Varchar
//abnormalhabit	     动植物习性	      Varchar
//abnormalphenomenon 物化现象          Varchar
//other	             其他	          Varchar
//implementation	 落实情况	          Varchar
//abnormalanalysis 	 初步分析	          Varchar
//credibly	         可信度	          Varchar

#import <Foundation/Foundation.h>

@interface AbnormalinfoModel : NSObject
@property (nonatomic, assign) float abnormalid;
@property (nonatomic, retain) NSString *abnormaltime;
@property (nonatomic, retain) NSString *informant;
@property (nonatomic, retain) NSString *abnormalintensity;
@property (nonatomic, retain) NSString *groundwater;
@property (nonatomic, retain) NSString *abnormalhabit;
@property (nonatomic, retain) NSString *abnormalphenomenon;
@property (nonatomic, retain) NSString *other;
@property (nonatomic, retain) NSString *implementation;
@property (nonatomic, retain) NSString *abnormalanalysis;
@property (nonatomic, retain) NSString *credibly;

@end
