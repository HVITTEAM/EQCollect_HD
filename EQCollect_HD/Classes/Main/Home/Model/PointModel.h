//
//  PointModel.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
//字段	          描述	          类型
//pointid	     调查点编号	      Int
//earthid	     地震编号	          Int
//pointlocation	 调查点地点	      Varchar
//pointlon	     调查点经度	      Float
//pointlat	     调查点经度	      Float
//pointname	     调查点名称	      Varchar
//pointtime	     生成时间	          Date
//pointgroup	 小组名称	          Varchar
//pointperson1	 小组成员1	      Date
//pointperson2	 小组成员2         Varchar
//pointintensity 评定烈度	          Varchar
//pointcontent	 调查简述	          Varchar

#import <Foundation/Foundation.h>

@interface PointModel : NSObject

@property (nonatomic, assign) float pointid;
@property (nonatomic, assign) float earthid;
@property (nonatomic, retain) NSString *pointlocation;
@property (nonatomic, retain) NSString *pointlon;
@property (nonatomic, retain) NSString *pointlat;
@property (nonatomic, retain) NSString *pointname;
@property (nonatomic, retain) NSString *totalname;
@property (nonatomic, retain) NSString *pointgroup;
@property (nonatomic, retain) NSString *pointperson1;
@property (nonatomic, retain) NSString *pointperson2;
@property (nonatomic, retain) NSString *pointintensity;
@property (nonatomic, assign) NSString *pointcontent;
@end
