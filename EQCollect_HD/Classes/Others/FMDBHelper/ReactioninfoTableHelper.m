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

#import "ReactioninfoTableHelper.h"

@implementation ReactioninfoTableHelper

+(ReactioninfoTableHelper *)sharedInstance
{
    static ReactioninfoTableHelper *reactioninfoTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        reactioninfoTableHelper = [[ReactioninfoTableHelper alloc] init];
        [reactioninfoTableHelper initDataBase];
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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' INTEGER, '%@' TEXT, '%@' INTEGER, '%@' INTEGER, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,REACTIONID,REACTIONTIME,
                                     INFORMANTNAME,INFORMANTEDUCATION,INFORMANTJOB,REACTIONADDRESS,ROCKFEELING,THROWFEELING,THROWTINGS,THROWDISTANCE,FALL,HANG,FURNITURESOUND,FURNITUREDUMP,SOUNDSIZE,SOUNDDIRECTION];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating db table");
        } else {
            NSLog(@"success to creating db table");
        }
        [db close];
    }
}

-(void) insertData
{
    if ([db open]) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')  VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                               TABLENAME,REACTIONID,REACTIONTIME,
                               INFORMANTNAME,INFORMANTEDUCATION,INFORMANTJOB,REACTIONADDRESS,ROCKFEELING,THROWFEELING,THROWTINGS,THROWDISTANCE,FALL,HANG,FURNITURESOUND,FURNITUREDUMP,SOUNDSIZE,SOUNDDIRECTION, @"张三",@"张三", @"济南",@"张三", @"13", @"济南",@"张三", @"13", @"济南",@"张三", @"13",@"张三",@"张三", @"济南",@"张三", @"13"];
        BOOL res = [db executeUpdate:insertSql1];
        if (!res) {
            NSLog(@"error when insert db table");
        } else {
            NSLog(@"success to insert db table");
        }
        [db close];
    }
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
-(void) deleteData
{
    if ([db open])
    {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@'",
                               TABLENAME, REACTIONID, @"张三"];
        BOOL res = [db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"error when delete db table");
        } else {
            NSLog(@"success to delete db table");
        }
        [db close];
    }
}

-(void) selectData
{
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@",TABLENAME];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            int reactionid = [rs intForColumn:REACTIONID];
            NSString * sounddirection = [rs stringForColumn:SOUNDDIRECTION];
            NSString * soundsize = [rs stringForColumn:SOUNDSIZE];
            NSString * hang = [rs stringForColumn:HANG];
            NSLog(@"id = %d, earthid = %@, pointlocation = %@  pointlon = %@", reactionid, sounddirection, soundsize, hang);
        }
        [db close];
    }
}

@end
