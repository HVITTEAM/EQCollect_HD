//
//  PictureInfoTableHelper.m
//  EQCollect_HD
//
//  Created by shi on 15/9/16.
//  Copyright (c) 2015年 董徐维. All rights reserved.
//

#import "PictureInfoTableHelper.h"
#import "PictureMode.h"

#define TABLENAME         @"pictureInfo"
#define PICTUREID         @"pictureid"
#define PICTURENAME       @"pictureName"
#define PICTUREPATH       @"picturePath"
#define POINTID           @"abnormalid"

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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (ID INTEGER PRIMARY KEY AUTOINCREMENT, '%@' TEXT, '%@' TEXT,'%@' TEXT)",TABLENAME,PICTURENAME,PICTUREPATH,POINTID];
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
                               @"INSERT INTO '%@' ('%@', '%@', '%@')  VALUES ('%@', '%@', '%@')",
                               TABLENAME,PICTURENAME,PICTUREPATH,POINTID,dict[@"pictureName"], dict[@"picturePath"],dict[@"abnormalid"]];
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

-(BOOL) deleteDataByPictureid:(NSString *)pictureidStr
{
    BOOL result = NO;
    if ([db open])
    {
        
        NSString *deleteSql = [NSString stringWithFormat:
                               @"delete from %@ where %@ = '%@'",
                               TABLENAME, PICTUREID, pictureidStr];
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


-(NSMutableArray *) selectDataByAttribute:(NSString *)attribute value:(NSString *)value;
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@ WHERE %@ ='%@'",TABLENAME,attribute,value];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
//            NSString * pictureid = [rs stringForColumn:PICTUREID];
            NSString * pictureName = [rs stringForColumn:PICTURENAME];
            NSString * picturePath = [rs stringForColumn:PICTUREPATH];
            NSString * pointid = [rs stringForColumn:POINTID];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
//            [dict setObject:pictureid forKey:@"pictureid"];
            [dict setObject:pictureName forKey:@"pictureName"];
            [dict setObject:picturePath forKey:@"picturePath"];
            [dict setObject:pointid forKey:@"pointid"];
            [dataCollect addObject:[PictureMode objectWithKeyValues:dict]];
        }
        [db close];
    }
    
    return dataCollect;
}

@end
