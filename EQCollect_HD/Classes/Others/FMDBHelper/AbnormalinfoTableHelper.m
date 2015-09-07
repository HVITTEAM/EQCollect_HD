//
//  AbnormalinfoTableHelper.m
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

#define TABLENAME          @"abnormalinfo"
#define ABNORMALID         @"abnormalid"
#define ABNORMALTIME       @"abnormaltime"
#define INFORMANT          @"informant"
#define ABNORMALINTENSITY  @"abnormalintensity"
#define GROUPDWATER        @"groundwater"
#define ABNORMALHABIT      @"abnormalhabit"
#define ABNORMALPHENOMENON @"abnormalphenomenon"
#define OTHER              @"other"
#define IMPLEMENTATION     @"implementation"
#define ABNORMALANALYSIS   @"abnormalanalysis"
#define CREDIBLY           @"credibly"

#import "AbnormalinfoTableHelper.h"

@implementation AbnormalinfoTableHelper

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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' INTEGER, '%@' TEXT, '%@' INTEGER, '%@' INTEGER, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,ABNORMALID,ABNORMALTIME,
                                     INFORMANT,ABNORMALINTENSITY,GROUPDWATER,ABNORMALHABIT,ABNORMALPHENOMENON,OTHER,IMPLEMENTATION,ABNORMALANALYSIS,CREDIBLY];
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
                               @"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')  VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                               TABLENAME,ABNORMALID,ABNORMALTIME,INFORMANT,ABNORMALINTENSITY,GROUPDWATER,ABNORMALHABIT,ABNORMALPHENOMENON,OTHER,IMPLEMENTATION,ABNORMALANALYSIS,CREDIBLY, @"张三",@"张三", @"济南",@"张三", @"13", @"济南",@"张三", @"13", @"济南",@"张三", @"13"];
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
                               TABLENAME, ABNORMALID, @"张三"];
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
            int abnormalid = [rs intForColumn:ABNORMALID];
            NSString * abnormaltime = [rs stringForColumn:ABNORMALTIME];
            NSString * abnormalintensity = [rs stringForColumn:ABNORMALINTENSITY];
            NSString * groundwater = [rs stringForColumn:GROUPDWATER];
            NSLog(@"id = %d, earthid = %@, pointlocation = %@  pointlon = %@", abnormalid, abnormaltime, abnormalintensity, groundwater);
        }
        [db close];
    }
}

@end
