//
//  PictureInfoTableHelper.m
//  EQCollect_HD
//
//  Created by shi on 15/9/16.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "PictureInfoTableHelper.h"
#import "PictureMode.h"

#define TABLENAME         @"PICTUREINFOTAB"
#define PICTUREID         @"pictureid"
#define PICTURENAME       @"pictureName"
#define PICTUREPATH       @"picturePath"
#define FOREIGNID         @"foreignid"
#define FOREIGNTABLE      @"foreigntable"

//#define POINTID           @"pointid"

@implementation PictureInfoTableHelper

+(PictureInfoTableHelper *)sharedInstance
{
    static PictureInfoTableHelper *pictureInfoTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pictureInfoTableHelper = [[PictureInfoTableHelper alloc] init];
        [pictureInfoTableHelper initDataBase];
        [pictureInfoTableHelper createTable];
    });
    return pictureInfoTableHelper;
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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@'INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' TEXT,'%@' TEXT,'%@' TEXT)",TABLENAME,PICTUREID,PICTURENAME,PICTUREPATH,FOREIGNID,FOREIGNTABLE];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating imgaedb table");
        } else {
            NSLog(@"success to creating imgaedb table");
        }
        [db close];
    }
}

-(BOOL) insertDataWith:(NSDictionary *)dict
{
    BOOL result = NO;
    if ([db open]) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@', '%@', '%@','%@')  VALUES ('%@', '%@', '%@','%@')",
                               TABLENAME,PICTURENAME,PICTUREPATH,FOREIGNID,FOREIGNTABLE,dict[@"pictureName"], dict[@"picturePath"],dict[@"foreignid"],dict[@"foreigntable"]];
        BOOL res = [db executeUpdate:insertSql1];
        if (!res) {
            NSLog(@"error when insert db Imgtable");
            result = NO;
        } else {
            NSLog(@"success to insert db Imgtable");
            result = YES;
        }
        [db close];
    }
    return result;
}

/**
 *  根据foreignid，foreigntable 字段删除相应的图片
 *
 *  @param foreigntable 关联的表名
 *  @param foreignid    关联表中某条记录的id
 */
-(BOOL) deleteDataByForeignTable:(NSString *)foreigntable Foreignid:(NSString *)foreignid
{
    BOOL result = NO;
    if ([db open])
    {

        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@' AND %@ = '%@'",
                               TABLENAME,FOREIGNTABLE,foreigntable,FOREIGNID, foreignid];
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

/**
 *  根据foreignid，foreigntable 字段查询相应的图片
 *
 *  @param foreigntable 关联的表名
 *  @param foreignid    关联表中某条记录的id
 */
-(NSMutableArray *) selectDataByForeignTable:(NSString *)foreigntable Foreignid:(NSString *)foreignid
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@ where %@ = '%@' AND %@ = '%@'",TABLENAME,FOREIGNTABLE,foreigntable,FOREIGNID,foreignid];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * pictureName = [rs stringForColumn:PICTURENAME];
            NSString * picturePath = [rs stringForColumn:PICTUREPATH];
            NSString * foreignid = [rs stringForColumn:FOREIGNID];
            NSString * foreigntable = [rs stringForColumn:FOREIGNTABLE];

            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:pictureName forKey:@"pictureName"];
            [dict setObject:picturePath forKey:@"picturePath"];
            [dict setObject:foreignid forKey:@"foreignid"];
            [dict setObject:foreigntable forKey:@"foreigntable"];
            
            [dataCollect addObject:[PictureMode objectWithKeyValues:dict]];
        }
        [db close];
    }

    return dataCollect;
}


@end
