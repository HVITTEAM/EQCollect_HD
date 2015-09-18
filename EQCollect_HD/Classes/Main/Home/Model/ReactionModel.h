//
//  ReactionModel.h
//  EQCollect_HD
//
//  Created by 董徐维 on 15/9/7.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//
//人物反应信息表(reactioninfo)
//字段	              描述	            类型
//reactionid	     人物反应编号	        Int
//reactiontime	     调查时间         	Date
//informantname  	 被调查者姓名	        Varchar
//informantage	     被调查者年龄	        Varchar
//informanteducation 被调查者学历	        Varchar
//informantjob	     被调查者职业	        Varchar
//reactionaddress	 所在地	            Varchar
//rockfeeling	     晃动感觉	            Varchar
//throwfeeling	     抛起感觉	            Varchar
//throwtings	     抛弃物	            Varchar
//throwdistance	     抛起距离       	    Varchar
//fall	             搁置物滚落	        Varchar
//hang            	 悬挂物	            Varchar
//furnituresound	 家具声响          	Varchar
//furnituredump	     家具倾倒	            Varchar
//soundsize	         地声大小	            Varchar
//sounddirection	 地声方向       	    Varchar
#import <Foundation/Foundation.h>

@interface ReactionModel : NSObject
@property (nonatomic, copy) NSString *reactionid;
@property (nonatomic, copy) NSString *reactiontime;
@property (nonatomic, copy) NSString *informantname;
@property (nonatomic, copy) NSString *informantage;
@property (nonatomic, copy) NSString *informanteducation;
@property (nonatomic, copy) NSString *informantjob;
@property (nonatomic, copy) NSString *reactionaddress;
@property (nonatomic, copy) NSString *rockfeeling;
@property (nonatomic, copy) NSString *throwfeeling;
@property (nonatomic, copy) NSString *throwtings;
@property (nonatomic, copy) NSString *throwdistance;
@property (nonatomic, copy) NSString *fall;
@property (nonatomic, copy) NSString *hang;
@property (nonatomic, copy) NSString *furnituresound;
@property (nonatomic, copy) NSString *furnituredump;
@property (nonatomic, copy) NSString *soundsize;
@property (nonatomic, copy) NSString *sounddirection;
@property (nonatomic, copy) NSString *pointid;

@end
