//
//  ReactioninfoTableHelper.m
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

#define TABLENAME          @"reactioninfo"
#define REACTIONID         @"reactionid"
#define REACTIONTIME       @"reactiontime"
#define INFORMANTNAME      @"informantname"
#define INFORMANTAGE       @"informantage"
#define INFORMANTEDUCATION @"informanteducation"
#define INFORMANTJOB       @"informantjob"
#define REACTIONADDRESS    @"reactionaddress"
#define ROCKFEELING        @"rockfeeling"
#define THROWFEELING       @"throwfeeling"
#define THROWTINGS         @"throwtings"
#define THROWDISTANCE      @"throwdistance"
#define FALL               @"fall"
#define HANG               @"hang"
#define FURNITURESOUND     @"furnituresound"
#define FURNITUREDUMP      @"furnituredump"
#define SOUNDSIZE          @"soundsize"
#define SOUNDDIRECTION     @"sounddirection"

#define POINTID            @"pointid"

#import "ReactioninfoTableHelper.h"

@implementation ReactioninfoTableHelper

+(ReactioninfoTableHelper *)sharedInstance
{
    static ReactioninfoTableHelper *reactioninfoTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reactioninfoTableHelper = [[ReactioninfoTableHelper alloc] init];
        [reactioninfoTableHelper initDataBase];
        [reactioninfoTableHelper createTable];
    });
    return reactioninfoTableHelper;
}

-(void)initDataBase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    database_path = [documents stringByAppendingPathComponent:DBNAME];
    
    db = [FMDatabase databaseWithPath:database_path];
}

- (void)createTable
{
    if ([db open]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT,'%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,REACTIONID,REACTIONTIME,
                                     INFORMANTNAME,INFORMANTAGE,INFORMANTEDUCATION,INFORMANTJOB,REACTIONADDRESS,ROCKFEELING,THROWFEELING,THROWTINGS,THROWDISTANCE,FALL,HANG,FURNITURESOUND,FURNITUREDUMP,SOUNDSIZE,SOUNDDIRECTION,POINTID];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating db table");
        } else {
            NSLog(@"success to creating db table");
        }
        [db close];
    }
}

-(BOOL) insertDataWith:(NSDictionary *)dict
{
    BOOL result = NO;
    if ([db open]) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@','%@')  VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@','%@','%@')",
                               TABLENAME,REACTIONID,REACTIONTIME,
                               INFORMANTNAME,INFORMANTAGE,INFORMANTEDUCATION,INFORMANTJOB,REACTIONADDRESS,ROCKFEELING,THROWFEELING,THROWTINGS,THROWDISTANCE,FALL,HANG,FURNITURESOUND,FURNITUREDUMP,SOUNDSIZE,SOUNDDIRECTION,POINTID, dict[@"reactionid"],dict[@"reactiontime"], dict[@"informantname"],dict[@"informantage"], dict[@"informanteducation"], dict[@"informantjob"],dict[@"reactionaddress"], dict[@"rockfeeling"],dict[@"throwfeeling"],dict[@"throwtings"],dict[@"throwdistance"],dict[@"fall"],dict[@"hang"], dict[@"furnituresound"],dict[@"furnituredump"], dict[@"soundsize"],dict[@"sounddirection"],dict[@"pointid"]];
        BOOL res = [db executeUpdate:insertSql1];
        if (!res) {
            NSLog(@"error when insert db table");
            result = NO;
        } else {
            NSLog(@"success to insert db table");
            result = YES;
        }
        [db close];
    }
    return result;
}
//
//-(void) updateData
//{
//    if ([db open])
//    {
//        NSString *updateSql = [NSString stringWithFormat:
//                               @"UPDATE '%@' SET '%@' = '%@' WHERE '%@' = '%@'",
//                               TABLENAME,   AGE,  @"15" ,AGE,  @"13"];
//        BOOL res = [db executeUpdate:updateSql];
//        if (!res) {
//            NSLog(@"error when update db table");
//        } else {
//            NSLog(@"success to update db table");
//        }
//        [db close];
//
//    }
//
//}
//
-(BOOL) deleteDataByReactionid:(NSString *)reactionidStr
{
    BOOL result = NO;
    if ([db open])
    {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@'",
                               TABLENAME, REACTIONID, reactionidStr];
        BOOL res = [db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"error when delete db table");
            result = NO;
        } else {
            NSLog(@"success to delete db table");
            result = YES;
        }
        [db close];
    }
    return result;
}

-(NSMutableArray *) selectData
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@",TABLENAME];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * reactionid = [rs stringForColumn:REACTIONID];
            NSString * reactiontime = [rs stringForColumn:REACTIONTIME];
            NSString * informantname = [rs stringForColumn:INFORMANTNAME];
            NSString * informantage = [rs stringForColumn:INFORMANTAGE];
            NSString * informanteducation = [rs stringForColumn:INFORMANTEDUCATION];
            NSString * informantjob = [rs stringForColumn:INFORMANTJOB];
            NSString * reactionaddress = [rs stringForColumn:REACTIONADDRESS];
            NSString * rockfeeling = [rs stringForColumn:ROCKFEELING];
            NSString * throwfeeling = [rs stringForColumn:THROWFEELING];
            NSString * throwtings = [rs stringForColumn:THROWTINGS];
            NSString * throwdistance = [rs stringForColumn:THROWDISTANCE];
            NSString * fall = [rs stringForColumn:FALL];
            NSString * hang = [rs stringForColumn:HANG];
            NSString * furnituresound = [rs stringForColumn:FURNITURESOUND];
            NSString * furnituredump = [rs stringForColumn:FURNITUREDUMP];
            NSString * sounddirection = [rs stringForColumn:SOUNDDIRECTION];
            NSString * soundsize = [rs stringForColumn:SOUNDSIZE];
            NSString * pointid = [rs stringForColumn:POINTID];

             NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:reactionid forKey:@"reactionid"];
            [dict setObject:reactiontime forKey:@"reactiontime"];
            [dict setObject:informantname forKey:@"informantname"];
            [dict setObject:informantage forKey:@"informantage"];
            [dict setObject:informanteducation forKey:@"informanteducation"];
            [dict setObject:informantjob forKey:@"informantjob"];
            [dict setObject:reactionaddress forKey:@"reactionaddress"];
            [dict setObject:rockfeeling forKey:@"rockfeeling"];
            [dict setObject:throwfeeling forKey:@"throwfeeling"];
            [dict setObject:throwtings forKey:@"throwtings"];
            [dict setObject:throwdistance forKey:@"throwdistance"];
            [dict setObject:fall forKey:@"fall"];
            [dict setObject:hang forKey:@"hang"];
            [dict setObject:furnituresound forKey:@"furnituresound"];
            [dict setObject:furnituredump forKey:@"furnituredump"];
            [dict setObject:soundsize forKey:@"soundsize"];
            [dict setObject:sounddirection forKey:@"sounddirection"];
            [dict setObject:pointid forKey:@"pointid"];
            
            [dataCollect addObject:[ReactionModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

-(NSMutableArray *) selectDataByAttribute:(NSString *)attribute value:(NSString *)value
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@ WHERE %@ ='%@'",TABLENAME,attribute,value];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * reactionid = [rs stringForColumn:REACTIONID];
            NSString * reactiontime = [rs stringForColumn:REACTIONTIME];
            NSString * informantname = [rs stringForColumn:INFORMANTNAME];
            NSString * informantage = [rs stringForColumn:INFORMANTAGE];
            NSString * informanteducation = [rs stringForColumn:INFORMANTEDUCATION];
            NSString * informantjob = [rs stringForColumn:INFORMANTJOB];
            NSString * reactionaddress = [rs stringForColumn:REACTIONADDRESS];
            NSString * rockfeeling = [rs stringForColumn:ROCKFEELING];
            NSString * throwfeeling = [rs stringForColumn:THROWFEELING];
            NSString * throwtings = [rs stringForColumn:THROWTINGS];
            NSString * throwdistance = [rs stringForColumn:THROWDISTANCE];
            NSString * fall = [rs stringForColumn:FALL];
            NSString * hang = [rs stringForColumn:HANG];
            NSString * furnituresound = [rs stringForColumn:FURNITURESOUND];
            NSString * furnituredump = [rs stringForColumn:FURNITUREDUMP];
            NSString * sounddirection = [rs stringForColumn:SOUNDDIRECTION];
            NSString * soundsize = [rs stringForColumn:SOUNDSIZE];
            NSString * pointid = [rs stringForColumn:POINTID];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:reactionid forKey:@"reactionid"];
            [dict setObject:reactiontime forKey:@"reactiontime"];
            [dict setObject:informantname forKey:@"informantname"];
            [dict setObject:informantage forKey:@"informantage"];
            [dict setObject:informanteducation forKey:@"informanteducation"];
            [dict setObject:informantjob forKey:@"informantjob"];
            [dict setObject:reactionaddress forKey:@"reactionaddress"];
            [dict setObject:rockfeeling forKey:@"rockfeeling"];
            [dict setObject:throwfeeling forKey:@"throwfeeling"];
            [dict setObject:throwtings forKey:@"throwtings"];
            [dict setObject:throwdistance forKey:@"throwdistance"];
            [dict setObject:fall forKey:@"fall"];
            [dict setObject:hang forKey:@"hang"];
            [dict setObject:furnituresound forKey:@"furnituresound"];
            [dict setObject:furnituredump forKey:@"furnituredump"];
            [dict setObject:soundsize forKey:@"soundsize"];
            [dict setObject:sounddirection forKey:@"sounddirection"];
            [dict setObject:pointid forKey:@"pointid"];
            
            [dataCollect addObject:[ReactionModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}


@end

