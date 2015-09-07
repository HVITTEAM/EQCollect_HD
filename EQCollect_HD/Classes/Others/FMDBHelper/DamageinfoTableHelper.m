//
//  DamageinfoTableHelper.m
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

#define TABLENAME        @"damageinfo"
#define DAMAGEID         @"damageid"
#define DAMAGETIME       @"damagetime"
#define DAMAGEADDRESS    @"damageaddress"
#define DAMAGEINTENSITY  @"damageintensity"
#define ZRCORXQ          @"zrcorxq"
#define DWORZH           @"dworzh"
#define FORTIFICATIONINTENSITY    @"fortificationintensity"
#define DAMAGESITUATION  @"damagesituation"
#define DAMAGEINDEX      @"damageindex"

#import "DamageinfoTableHelper.h"

@implementation DamageinfoTableHelper

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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' INTEGER PRIMARY KEY AUTOINCREMENT, '%@' INTEGER, '%@' TEXT, '%@' INTEGER, '%@' INTEGER, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,DAMAGEID,DAMAGETIME,
                                     DAMAGEADDRESS,DAMAGEINTENSITY,ZRCORXQ,DWORZH,FORTIFICATIONINTENSITY,DAMAGESITUATION,DAMAGEINDEX];
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
                               @"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')  VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                               TABLENAME,DAMAGEID,DAMAGETIME,DAMAGEADDRESS,DAMAGEINTENSITY,ZRCORXQ,DWORZH,FORTIFICATIONINTENSITY,DAMAGESITUATION,DAMAGEINDEX, @"张三",@"张三", @"济南",@"张三", @"13", @"济南",@"张三", @"13", @"济南"];
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
                               TABLENAME, DAMAGEID, @"张三"];
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
            int damageid = [rs intForColumn:DAMAGEID];
            NSString * damagetime = [rs stringForColumn:DAMAGETIME];
            NSString * damageaddress = [rs stringForColumn:DAMAGEADDRESS];
            NSString * damageintensity = [rs stringForColumn:DAMAGEINTENSITY];
            NSLog(@"id = %d, earthid = %@, pointlocation = %@  pointlon = %@", damageid, damagetime, damageaddress, damageintensity);
        }
        [db close];
    }
}

@end
