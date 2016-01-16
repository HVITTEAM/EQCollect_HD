//
//  OtherTableHelper.m
//  EQCollect_HD
//
//  Created by shi on 15/12/10.
//  Copyright © 2015年 董徐维. All rights reserved.
//


#define TABLENAME        @"OTHERTAB"
#define kOtherid          @"otherid"
#define kOthercontent     @"othercontent"
#define kOtherlon         @"otherlon"
#define kOtherlat         @"otherlat"
#define kOtheraddress     @"otheraddress"
#define kOthertime        @"othertime"

#define kPointid          @"pointid"
#define kUploadFlag       @"upload"


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
        NSString *sqlCreateTable =  [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' ('%@' PRIMARY KEY,'%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT, '%@' TEXT)",TABLENAME,kOtherid,kOthercontent,kOtherlon,kOtherlat,kOtheraddress,kOthertime,kPointid,kUploadFlag];
        BOOL res = [db executeUpdate:sqlCreateTable];
        if (!res) {
            NSLog(@"error when creating other table");
        } else {
            NSLog(@"success to creating other table");
        }
        [db close];
    }
}

-(BOOL)insertDataWithOtherinfoModel:(OtherModel *)model
{
    BOOL res = NO;
    if ([db open]) {
        NSString *insertSql= [NSString stringWithFormat:
                               @"INSERT INTO '%@' ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@')  VALUES ('%@','%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                               TABLENAME,kOtherid,kOthercontent,kOtherlon,kOtherlat,kOtheraddress,kOthertime,kPointid,kUploadFlag,model.otherid,model.othercontent,model.otherlon,model.otherlat,model.otheraddress,model.othertime,model.pointid,model.upload];
        res = [db executeUpdate:insertSql];
        if (!res) {
            NSLog(@"error when insert other table");
        } else {
            NSLog(@"success to insert other table");
        }
        [db close];
    }
    return res;
}

-(BOOL)updateDataWithOtherinfoModel:(OtherModel *)model
{
    BOOL res = NO;
    if ([db open])
    {
        NSString *updateSql = [NSString stringWithFormat:
                               @"UPDATE %@ SET %@ = '%@',%@ = '%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@', %@='%@' WHERE %@ = '%@' ",TABLENAME,kOtherid,model.otherid,kOthercontent,model.othercontent,kOtherlon,model.otherlon,kOtherlat,model.otherlat,kOtheraddress,model.otheraddress,kOthertime,model.othertime,kPointid,model.pointid,kUploadFlag,model.upload,kOtherid,model.otherid];
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
                               @"UPDATE %@ SET %@ = '%@' WHERE %@ = '%@' ",TABLENAME,kUploadFlag,uploadFlag,kOtherid,idString];
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
        NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where %@ = '%@'",TABLENAME, attribute, value];
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

-(NSMutableArray *)selectData
{
    NSMutableArray *dataCollect = [[NSMutableArray alloc] init];
    if ([db open])
    {
        NSString * sql = [NSString stringWithFormat: @"SELECT * FROM %@",TABLENAME];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next])
        {
            NSString * otherid = [rs stringForColumn:kOtherid];
            NSString * othercontent = [rs stringForColumn:kOthercontent];
            NSString * otherlon = [rs stringForColumn:kOtherlon];
            NSString * otherlat = [rs stringForColumn:kOtherlat];
            NSString * otheraddress = [rs stringForColumn:kOtheraddress];
            NSString * othertime = [rs stringForColumn:kOthertime];
            NSString * pointid = [rs stringForColumn:kPointid];
            NSString * upload = [rs stringForColumn:kUploadFlag];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:otherid forKey:kOtherid];
            [dict setObject:othercontent forKey:kOthercontent];
            [dict setObject:otherlon forKey:kOtherlon];
            [dict setObject:otherlat forKey:kOtherlat];
            [dict setObject:otheraddress forKey:kOtheraddress];
            [dict setObject:othertime forKey:kOthertime];
            [dict setObject:pointid forKey:kPointid];
            [dict setObject:upload forKey:kUploadFlag];
            
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
            NSString * otherid = [rs stringForColumn:kOtherid];
            NSString * othercontent = [rs stringForColumn:kOthercontent];
            NSString * otherlon = [rs stringForColumn:kOtherlon];
            NSString * otherlat = [rs stringForColumn:kOtherlat];
            NSString * otheraddress = [rs stringForColumn:kOtheraddress];
            NSString * othertime = [rs stringForColumn:kOthertime];
            NSString * pointid = [rs stringForColumn:kPointid];
            NSString * upload = [rs stringForColumn:kUploadFlag];
            
            NSMutableDictionary *dict = [NSMutableDictionary new];
            [dict setObject:otherid forKey:kOtherid];
            [dict setObject:othercontent forKey:kOthercontent];
            [dict setObject:otherlon forKey:kOtherlon];
            [dict setObject:otherlat forKey:kOtherlat];
            [dict setObject:otheraddress forKey:kOtheraddress];
            [dict setObject:othertime forKey:kOthertime];
            [dict setObject:pointid forKey:kPointid];
            [dict setObject:upload forKey:kUploadFlag];
            
            [dataCollect addObject:[OtherModel objectWithKeyValues:dict]];
        }
        [db close];
    }
    return dataCollect;
}

@end
