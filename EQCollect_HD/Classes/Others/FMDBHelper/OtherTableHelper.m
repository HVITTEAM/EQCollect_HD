//
//  OtherTableHelper.m
//  EQCollect_HD
//
//  Created by shi on 15/12/10.
//  Copyright © 2015年 董徐维. All rights reserved.
//


#define TABLENAME        @"OTHERTAB"
#define OTHERID          @"otherid"
#define OTHERCONTENT     @"othercontent"
#define OTHERLON         @"otherlon"
#define OTHERLAT         @"otherlat"
#define OTHERADDRESS     @"otheraddress"
#define OTHERTIME        @"othertime"
#define POINTID          @"pointid"
#define UPLOAD           @"upload"

#import "OtherTableHelper.h"

@implementation OtherTableHelper

+(OtherTableHelper *)sharedInstance
{
    static OtherTableHelper *otherTableHelper;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        otherTableHelper = [[OtherTableHelper alloc] init];
        [otherTableHelper initDataBase];
        [otherTableHelper createTable];
        
    });
    return otherTableHelper;
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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' PRIMARY KEY,'%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,OTHERID,OTHERCONTENT,
                                     OTHERLON,OTHERLAT,OTHERADDRESS,OTHERTIME,POINTID,UPLOAD];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating other table");
        } else {
            NSLog(@"success to creating other table");
        }
        [db close];
    }
}

-(BOOL) insertDataWith:(NSDictionary *)dict
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql1= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@')  VALUES ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                               TABLENAME,OTHERID,OTHERCONTENT,OTHERLON,OTHERLAT,OTHERADDRESS,OTHERTIME,POINTID,UPLOAD,dict[@"otherid"],dict[@"othercontent"], dict[@"otherlon"],dict[@"otherlat"], dict[@"otheraddress"], dict[@"othertime"],dict[@"pointid"],dict[@"upload"]];
       res = [db executeUpdate:insertSql1];
        if (!res) {
             NSLog(@"error when insert other table");
        } else {
            NSLog(@"success to insert other table");
        }
        [db close];
    }
    return res;
}

-(BOOL) updateDataWith:(NSDictionary *)dict
{
    BOOL res = NO;
    if ([db open])
    {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@',%@ = '%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@' WHERE %@ = '%@' ",TABLENAME,OTHERID,dict[@"otherid"],OTHERCONTENT,dict[@"othercontent"],OTHERLON,dict[@"otherlon"],OTHERLAT,dict[@"otherlat"],OTHERADDRESS,dict[@"otheraddress"],OTHERTIME,dict[@"othertime"],POINTID,dict[@"pointid"],UPLOAD,dict[@"upload"],OTHERID,dict[@"otherid"]];
        res = [db executeUpdate:updateSql];
        if (!res) {
            NSLog(@"error when update other table");
        } else {
            NSLog(@"success to update other table");
        }
        [db close];
    }
    return res;
}

-(BOOL)updateUploadFlag:(NSString *)uploadFlag ID:(NSString *)idString
{
    BOOL result = NO;
    if ([db open]) {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@' ",TABLENAME,UPLOAD,uploadFlag,OTHERID,idString];
        result = [db executeUpdate:updateSql];
        if (!result) {
            NSLog(@"error when update other table");
        }else{
            NSLog(@"success to update other table");
        }
        [db close];
    }
    return result;
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
            NSLog(@"error when delete other table");
        } else {
            NSLog(@"success to delete other table");
        }
        [db close];
    }
    return res;
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
            NSString * otherid = [rs stringForColumn:OTHERID];
            NSString * othercontent = [rs stringForColumn:OTHERCONTENT];
            NSString * otherlon = [rs stringForColumn:OTHERLON];
            NSString * otherlat = [rs stringForColumn:OTHERLAT];
            NSString * otheraddress = [rs stringForColumn:OTHERADDRESS];
            NSString * othertime = [rs stringForColumn:OTHERTIME];
            NSString * pointid = [rs stringForColumn:POINTID];
            NSString * upload = [rs stringForColumn:UPLOAD];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:otherid forKey:@"otherid"];
            [dict setObject:othercontent forKey:@"othercontent"];
            [dict setObject:otherlon forKey:@"otherlon"];
            [dict setObject:otherlat forKey:@"otherlat"];
            [dict setObject:otheraddress forKey:@"otheraddress"];
            [dict setObject:othertime forKey:@"othertime"];
            [dict setObject:pointid forKey:@"pointid"];
            [dict setObject:upload forKey:@"upload"];
            
            [dataCollect addObject:[OtherModel objectWithKeyValues:dict]];  
        }
        [db close];
    }
    
    return dataCollect;
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
            NSString * otherid = [rs stringForColumn:OTHERID];
            NSString * othercontent = [rs stringForColumn:OTHERCONTENT];
            NSString * otherlon = [rs stringForColumn:OTHERLON];
            NSString * otherlat = [rs stringForColumn:OTHERLAT];
            NSString * otheraddress = [rs stringForColumn:OTHERADDRESS];
            NSString * othertime = [rs stringForColumn:OTHERTIME];
            NSString * pointid = [rs stringForColumn:POINTID];
            NSString * upload = [rs stringForColumn:UPLOAD];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:otherid forKey:@"otherid"];
            [dict setObject:othercontent forKey:@"othercontent"];
            [dict setObject:otherlon forKey:@"otherlon"];
            [dict setObject:otherlat forKey:@"otherlat"];
            [dict setObject:otheraddress forKey:@"otheraddress"];
            [dict setObject:othertime forKey:@"othertime"];
            [dict setObject:pointid forKey:@"pointid"];
            [dict setObject:upload forKey:@"upload"];
            
            [dataCollect addObject:[OtherModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}



@end
