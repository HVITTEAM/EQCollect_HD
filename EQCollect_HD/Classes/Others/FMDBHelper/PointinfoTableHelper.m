//
//  FMDBHelper.m
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


#define TABLENAME      @"POINTINFOTAB"
#define POINTID        @"pointid"
#define EARTHID        @"earthid"
#define POINTLOCATION  @"pointlocation"
#define POINTLON       @"pointlon"
#define POINTLAT       @"pointlat"
#define POINTNAME      @"pointname"
#define POINTTIME      @"pointtime"
#define POINTGROUP     @"pointgroup"
#define POINTPERSON1   @"pointperson1"
#define POINTPERSON2   @"pointperson2"
#define POINTINTENSITY @"pointintensity"
#define POINTCONTENT   @"pointcontent"
#define UPLOAD         @"upload"

#import "PointinfoTableHelper.h"


@implementation PointinfoTableHelper

+(PointinfoTableHelper *)sharedInstance
{
    static PointinfoTableHelper *pointinfoTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pointinfoTableHelper = [[PointinfoTableHelper alloc] init];
        [pointinfoTableHelper initDataBase];
        [pointinfoTableHelper createTable];
    });
    return pointinfoTableHelper;
}

-(void)initDataBase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    database_path = [documents stringByAppendingPathComponent:DBNAME];
    NSLog(@"----pointinfoTableHelper-----%@",database_path);
    db = [FMDatabase databaseWithPath:database_path];
}
//integer primary key autoincrement
- (void)createTable
{
    if ([db open]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@'INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,POINTID,EARTHID,POINTLOCATION,POINTLON,POINTLAT,POINTNAME,POINTTIME,POINTGROUP,POINTPERSON1,POINTPERSON2,POINTINTENSITY,POINTCONTENT,UPLOAD];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            //NSLog(@"error when creating db table");
        } else {
            //NSLog(@"success to creating db table");
        }
        [db close];
    }
}

-(BOOL) insertDataWith:(NSDictionary *)dict
{
    BOOL result = NO;
    if ([db open]) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')  VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                               TABLENAME, EARTHID, POINTLOCATION,POINTLON,POINTLAT,POINTNAME,POINTTIME,POINTGROUP,POINTPERSON1,POINTPERSON2,POINTINTENSITY,POINTCONTENT,UPLOAD,dict[@"earthid"],dict[@"pointlocation"], dict[@"pointlon"], dict[@"pointlat"],dict[@"pointname"], dict[@"pointtime"], dict[@"pointgroup"],dict[@"pointperson1"], dict[@"pointperson2"], dict[@"pointintensity"], dict[@"pointcontent"],dict[@"upload"]];
        BOOL res = [db executeUpdate:insertSql1];
        if (!res) {
            //NSLog(@"error when insert db table");
            result = NO;
        } else {
            //NSLog(@"success to insert db table");
            result = YES;
        }
        [db close];
    }
    return result;
}

-(BOOL) updateDataWith:(NSDictionary *)dict
{
    BOOL result = NO;
    if ([db open])
    {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@',%@='%@', %@='%@', %@='%@' WHERE %@ = %@  ",TABLENAME,EARTHID,dict[@"earthid"],POINTLOCATION,dict[@"pointlocation"],POINTLON,dict[@"pointlon"],POINTLAT,dict[@"pointlat"],POINTNAME,dict[@"pointname"],POINTTIME,dict[@"pointtime"],POINTGROUP,dict[@"pointgroup"],POINTPERSON1,dict[@"pointperson1"],POINTPERSON2,dict[@"pointperson2"],POINTINTENSITY,dict[@"pointintensity"],POINTCONTENT,dict[@"pointcontent"],UPLOAD,dict[@"upload"],POINTID,dict[@"pointid"]];
        BOOL res = [db executeUpdate:updateSql];
        if (!res) {
            //NSLog(@"error when update db table");
            result = NO;
        } else {
            //NSLog(@"success to update db table");
            result = YES;
        }
        [db close];
    }
    return result;
}

-(BOOL)updateUploadFlag:(NSString *)uploadFlag ID:(NSString *)idString
{
    BOOL result = NO;
    if ([db open]) {
        NSString *updateSql = [NSString stringWithFormat:
                            @"UPDATE %@ SET %@ = '%@' WHERE %@ = %@ ",TABLENAME,UPLOAD,uploadFlag,POINTID,idString];
        NSLog(@"%@",updateSql);
        result = [db executeUpdate:updateSql];
        if (!result) {
            NSLog(@"error when update db table");
        }else{
            NSLog(@"success to update db table");
        }
      [db close];
    }
    return result;
}

-(BOOL) deleteDataByAttribute:(NSString *)attribute value:(NSString *)value
{
    BOOL result = NO;
    if ([db open])
    {

        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@'",
                               TABLENAME, attribute, value];
        BOOL res = [db executeUpdate:deleteSql];

        if (!res) {
            //NSLog(@"error when delete db table");
            result = NO;
        } else {
            //NSLog(@"success to delete db table");
            result = YES;
        }
        [db close];
    }
    return result;
}

- (NSMutableArray *)selectData;
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@",TABLENAME];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * pointid = [rs stringForColumn:POINTID];
            NSString * earthid = [rs stringForColumn:EARTHID];
            NSString * pointlocation = [rs stringForColumn:POINTLOCATION];
            NSString * pointlon = [rs stringForColumn:POINTLON];
            NSString * pointlat = [rs stringForColumn:POINTLAT];
            NSString * pointname = [rs stringForColumn:POINTNAME];
            NSString * pointtime = [rs stringForColumn:POINTTIME];
            NSString * pointgroup = [rs stringForColumn:POINTGROUP];
            NSString * pointperson1 = [rs stringForColumn:POINTPERSON1];
            NSString * pointperson2 = [rs stringForColumn:POINTPERSON2];
            NSString * pointintensity = [rs stringForColumn:POINTINTENSITY];
            NSString * pointcontent = [rs stringForColumn:POINTCONTENT];
            NSString * upload = [rs stringForColumn:UPLOAD];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:pointid forKey:@"pointid"];
            [dict setObject:earthid forKey:@"earthid"];
            [dict setObject:pointlocation forKey:@"pointlocation"];
            [dict setObject:pointlon forKey:@"pointlon"];
            [dict setObject:pointlat forKey:@"pointlat"];
            [dict setObject:pointname forKey:@"pointname"];
            [dict setObject:pointtime forKey:@"pointtime"];
            [dict setObject:pointgroup forKey:@"pointgroup"];
            [dict setObject:pointperson1 forKey:@"pointperson1"];
            [dict setObject:pointperson2 forKey:@"pointperson2"];
            [dict setObject:pointintensity forKey:@"pointintensity"];
            [dict setObject:pointcontent forKey:@"pointcontent"];
            [dict setObject:upload forKey:@"upload"];

            [dataCollect addObject:[PointModel objectWithKeyValues:dict]];
            
        }
        [db close];
    }
    return dataCollect;
}

//-(void) multithread
//{
//    FMDatabaseQueue * queue = [FMDatabaseQueue databaseQueueWithPath:database_path];
//    dispatch_queue_t q1 = dispatch_queue_create("queue1", NULL);
//    dispatch_queue_t q2 = dispatch_queue_create("queue2", NULL);
//
//    dispatch_async(q1, ^{
//        for (int i = 0; i < 50; ++i) {
//            [queue inDatabase:^(FMDatabase *db2) {
//
//                NSString *insertSql1= [NSString stringWithFormat:
//                                       @"INSERT INTO '%@' ('%@', '%@', '%@') VALUES (?, ?, ?)",
//                                       TABLENAME, NAME, AGE, ADDRESS];
//
//                NSString * name = [NSString stringWithFormat:@"jack %d", i];
//                NSString * age = [NSString stringWithFormat:@"%d", 10+i];
//
//
//                BOOL res = [db2 executeUpdate:insertSql1, name, age,@"济南"];
//                if (!res) {
//                    NSLog(@"error to inster data: %@", name);
//                } else {
//                    NSLog(@"succ to inster data: %@", name);
//                }
//            }];
//        }
//    });
//
//    dispatch_async(q2, ^{
//        for (int i = 0; i < 50; ++i) {
//            [queue inDatabase:^(FMDatabase *db2) {
//                NSString *insertSql2= [NSString stringWithFormat:
//                                       @"INSERT INTO '%@' ('%@', '%@', '%@') VALUES (?, ?, ?)",
//                                       TABLENAME, NAME, AGE, ADDRESS];
//
//                NSString * name = [NSString stringWithFormat:@"lilei %d", i];
//                NSString * age = [NSString stringWithFormat:@"%d", 10+i];
//
//                BOOL res = [db2 executeUpdate:insertSql2, name, age,@"北京"];
//                if (!res) {
//                    NSLog(@"error to inster data: %@", name);
//                } else {
//                    NSLog(@"succ to inster data: %@", name);
//                }
//            }];
//        }
//    });
//}

@end
