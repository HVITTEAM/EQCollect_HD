//
//  TrackTableHelper.m
//  EQCollect_HD
//
//  Created by shi on 15/11/30.
//  Copyright © 2015年 董徐维. All rights reserved.
//

#import "TrackTableHelper.h"
#import "TrackModel.h"

#define TABLENAME         @"TRACKTAB"
#define kTrackTime              @"time"
#define kTrackLon               @"lon"
#define kTrackLat               @"lat"

@implementation TrackTableHelper
+(TrackTableHelper *)sharedInstance
{
    static TrackTableHelper *trackTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trackTableHelper = [[TrackTableHelper alloc] init];
        [trackTableHelper initDataBase];
        [trackTableHelper createTable];
    });
    return trackTableHelper;
}

-(void)initDataBase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    database_path = [documents stringByAppendingPathComponent:DBNAME];
    db = [FMDatabase databaseWithPath:database_path];
}

-(void)createTable
{
    if ([db open]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,kTrackTime,kTrackLon,kTrackLat];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating track table");
        } else {
            NSLog(@"success to creating track table");
        }
        [db close];
    }
}

-(BOOL)insertDataWithTrackinfoModel:(TrackModel *)model
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql = [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@', '%@')  VALUES ('%@','%@', '%@')",
                               TABLENAME,kTrackTime,kTrackLon,kTrackLat,model.time,model.lon,model.lat];
        res = [db executeUpdate:insertSql];
        if (!res) {
            NSLog(@"error when insert track table");
        } else {
            NSLog(@"success to insert track table");
        }
        [db close];
    }
    return res;
}

-(BOOL)deleteDataByAttribute:(NSString *)attribute value:(NSString *)value
{
    BOOL res = NO;
    if ([db open])
    {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@'",
                               TABLENAME, attribute, value];
        res = [db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"error when delete track table");
        } else {
            NSLog(@"success to delete track table");
        }
        [db close];
    }
    return res;
}

-(BOOL)deleteTracksOfBeforeDay:(NSString *)aDayString
{
    BOOL res = NO;
    if ([db open])
    {
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ < '%@'",
                               TABLENAME, @"time", aDayString];
        res = [db executeUpdate:deleteSql];
        
        if (!res) {
            NSLog(@"error when delete track table");
        } else {
            NSLog(@"success to delete track table");
        }
        [db close];
    }
    return res;
}

-(NSMutableArray *)selectDataByAttribute:(NSString *)attribute value:(NSString *)value;
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@ WHERE %@ LIKE'%@%%'",TABLENAME,attribute,value];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * time = [rs stringForColumn:kTrackTime];
            NSString * lon = [rs stringForColumn:kTrackLon];
            NSString * lat = [rs stringForColumn:kTrackLat];

            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:time forKey:kTrackTime];
            [dict setObject:lon forKey:kTrackLon];
            [dict setObject:lat forKey:kTrackLat];

            [dataCollect addObject:[TrackModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

@end
