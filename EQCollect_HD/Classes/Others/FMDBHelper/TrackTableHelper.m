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
#define TIME              @"time"
#define LON               @"lon"
#define LAT               @"lat"

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

- (void)createTable
{
    if ([db open]) {
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,TIME,LON,LAT];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating track table");
        } else {
            NSLog(@"success to creating track table");
        }
        [db close];
    }
}

-(BOOL) insertDataWith:(NSDictionary *)dict
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@', '%@')  VALUES ('%@','%@', '%@')",
                               TABLENAME,TIME,LON,LAT,dict[@"time"],dict[@"lon"], dict[@"lat"]];
        res = [db executeUpdate:insertSql1];
        if (!res) {
            NSLog(@"error when insert track table");
        } else {
            NSLog(@"success to insert track table");
        }
        [db close];
    }
    return res;
}

-(BOOL) deleteDataByAttribute:(NSString *)attribute value:(NSString *)value
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

-(NSMutableArray *) selectDataByAttribute:(NSString *)attribute value:(NSString *)value;
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@ WHERE %@ LIKE'%@'",TABLENAME,attribute,value];
        NSLog(@"------------%@",sql);
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * time = [rs stringForColumn:TIME];
            NSString * lon = [rs stringForColumn:LON];
            NSString * lat = [rs stringForColumn:LAT];

            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:time forKey:@"time"];
            [dict setObject:lon forKey:@"lon"];
            [dict setObject:lat forKey:@"lat"];

            
            [dataCollect addObject:[TrackModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

@end
