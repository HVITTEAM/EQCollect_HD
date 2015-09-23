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
#define RELETEID          @"releteid"
#define RELETETABLE       @"reletetable"

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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@'INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' TEXT,'%@' TEXT,'%@' TEXT)",TABLENAME,PICTUREID,PICTURENAME,PICTUREPATH,RELETEID,RELETETABLE];
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
                               TABLENAME,PICTURENAME,PICTUREPATH,RELETEID,RELETETABLE,dict[@"pictureName"], dict[@"picturePath"],dict[@"releteid"],dict[@"reletetable"]];
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
 *  根据releteid，reletetable 字段删除相应的图片
 *
 *  @param reletetable 关联的表名
 *  @param releteid    关联表中某条记录的id
 */
-(BOOL) deleteDataByReleteTable:(NSString *)reltable Releteid:(NSString *)relid
{
    BOOL result = NO;
    if ([db open])
    {

        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@' AND %@ = '%@'",
                               TABLENAME,RELETETABLE,reltable,RELETEID, relid];
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
 *  根据releteid，reletetable 字段查询相应的图片
 *
 *  @param reletetable 关联的表名
 *  @param releteid    关联表中某条记录的id
 */
-(NSMutableArray *) selectDataByReleteTable:(NSString *)reltable Releteid:(NSString *)relid
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@ where %@ = '%@' AND %@ = '%@'",TABLENAME,RELETETABLE,reltable,RELETEID,relid];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * pictureName = [rs stringForColumn:PICTURENAME];
            NSString * picturePath = [rs stringForColumn:PICTUREPATH];
            NSString * releteid = [rs stringForColumn:RELETEID];
            NSString * reletetable = [rs stringForColumn:RELETETABLE];

            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:pictureName forKey:@"pictureName"];
            [dict setObject:picturePath forKey:@"picturePath"];
            [dict setObject:releteid forKey:@"releteid"];
            [dict setObject:reletetable forKey:@"reletetable"];
            
            [dataCollect addObject:[PictureMode objectWithKeyValues:dict]];
        }
        [db close];
    }

    return dataCollect;
}

/**
 *  从沙盒目录中删除图片
 *
 *  @param reltable 关联的表
 *  @param relid    关联记录的 ID
 *
 *  @return  成功返回 yes，失败返回 no
 */
-(BOOL)deletePictureFromDocumentDirectoryByReleteTable:(NSString *)reltable Releteid:(NSString *)relid
{
    NSMutableArray *parhs = [[NSMutableArray alloc] init];
    if ([db open]) {
        NSString * sql = [NSString stringWithFormat: @"SELECT %@ FROM %@ where %@ = '%@' AND %@ = '%@'",PICTUREPATH,TABLENAME,RELETETABLE,reltable,RELETEID,relid];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            NSString *picturePath = [rs stringForColumnIndex:0];
            [parhs addObject:picturePath];
        }
        [db close];
    }
    for (int i=0; i<parhs.count; i++) {
       BOOL result = [[NSFileManager defaultManager]removeItemAtPath:parhs[i] error:nil];
       if (!result) {
           return result;
        }
    }
    return YES;
}

@end
